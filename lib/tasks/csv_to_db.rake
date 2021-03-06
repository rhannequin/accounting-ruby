# frozen_string_literal: true

require "yaml"

task csv_to_db: :environment do
  puts
  puts "Emptying database..."
  Tagging.destroy_all
  Tag.destroy_all
  Expense.destroy_all
  Account.destroy_all
  puts "... done."
  puts

  accounts = [
    {
      expenses_file: "tmp/1/data.csv",
      config_file: "tmp/1/config.yml",
      name: "Account #1",
      users: User.all
    }, {
      expenses_file: "tmp/2/data.csv",
      config_file: "tmp/2/config.yml",
      name: "Account #2",
      users: [User.find_by(name: "rhannequin")]
    }
  ]

  accounts.each do |account|
    puts "Creating account \"#{account[:name]}\"..."

    expenses = []
    tags = []
    account_id = Account.create!(name: account[:name], users: account[:users]).id

    puts "... done."
    puts

    config = YAML.load_file(account[:config_file])

    SmarterCSV.process(account[:expenses_file],
        chunk_size: 10000,
        headers_in_file: true,
        file_encoding: "utf-8",
        col_sep: ";",
        row_sep: "\n",
        strip_whitespace: true,
        key_mapping: {
          date: :date,
          objet: :reason,
          prix: :price,
          catégories: :tags
        }
    ) do |array|
      array.each do |hash|
        hash[:date] = Date.strptime(hash[:date], "%d/%m/%y")
        hash[:tags] ||= ""
        hash[:account_id] = account_id
        expense_tags = hash[:tags].split(",").map do |t|
          tag = { name: t.strip, account_id: account_id }
          tags << tag unless tags.include?(tag)
          tag
        end
        hash.delete(:tags)
        expense = Expense.new(hash)
        expense_tags.each { |t| expense.tags.build(t) }
        expenses << expense
      end
    end

    puts "Inserting tags in \"#{account[:name]}\"..."
    Tag.import(tags.map { |t| Tag.new(t) })
    puts "... done. (#{Tag.count})"
    puts

    puts "Inserting expenses in \"#{account[:name]}\"..."
    Expense.import expenses
    ActiveRecord::Base.transaction do
      expenses.each do |expense|
        e = Expense.find_by(
          reason: expense.reason,
          date: expense.date,
          price: expense.price
        )
        e.tags << expense.tags.map { |t| Tag.find_by(name: t.name, account_id: account_id) }
        e.save
      end
    end
    puts "... done. (#{Expense.count})"
    puts

    puts "Inserting start amount in \"#{account[:name]}\"..."
    start_amount = config["start_amount"]
    first_expense = Expense.select(:date).order(:date).first
    Expense.create!(
      reason: "Start amount",
      date: first_expense.date,
      price: start_amount,
      account_id: account_id
    )
    puts "... done."
    puts
  end

  puts "Updating all tags slugs..."
  Tag.find_each { |t| t.save! }
  puts "... done. (#{Tag.count})"
  puts
end
