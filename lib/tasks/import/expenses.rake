# frozen_string_literal: true

require "nokogiri"
require "date"
require "yaml"
require "pp"

require_relative "expense_parser"


namespace :import do
  task expenses: :environment do
    start_time = Time.now
    puts
    puts "== Start importing task at #{start_time} =="
    puts
    clean_database
    process_loop
    end_time = Time.now
    puts
    puts "== End importing task at #{end_time} (#{(end_time - start_time).round(2)} seconds) =="
    puts
  end
end


def clean_database
  start_time = Time.now
  puts
  puts "Emptying database..."
  Account.destroy_all
  end_time = Time.now
  puts "... done in (#{(end_time - start_time).round(2)} seconds)."
  puts
end


def process_loop
  config = YAML.load_file(Rails.root.join("lib", "tasks", "import", "expenses_config.yml"))
  config.fetch("accounts").each do |data|
    account = Account.create(name: data.fetch("name"))
    account_owners = data.fetch("owners").map { |o| User.find_by(name: o) }
    account.users = account_owners
    puts
    puts "== Start importing expenses from #{account.name} for #{account_owners.map(&:name).join(", ")} =="
    result = process_import(data, account)
    puts "== End importing expenses from #{account.name} =="
    puts "== Imported #{result[:imported]} transactions =="
    puts
  end
end


def process_import(data, account)
  filename = Rails.root.join("tmp", "expenses", data.fetch("file"))
  doc = File.open(filename) { |f| Nokogiri::HTML(f, nil, Encoding::UTF_8.to_s) }
  transactions = doc.css("ul.transactionList li")
  expenses = []
  tags = []
  transactions.each do |entry|
    next if entry.attr("id").nil?
    parsed = ExpenseParser.new(entry).parse
    tag = {
      name: parsed[:tag],
      ignored: false,
      account: account,
      expense_bankin_id: parsed[:bankin_id]
    }
    if data.fetch("ignored").map { |ign| parsed[:reason].include?(ign) }.include?(true)
      tags << { name: "ignore", ignored: true, account: account, expense_bankin_id: parsed[:bankin_id] }
    end
    tags << tag
    expenses << Expense.new(parsed.except(:tag).merge(account: account))
  end
  Expense.import(expenses)
  tags.each do |tag|
    t = Tag.find_or_initialize_by(tag.except(:expense_bankin_id))
    t.expenses << Expense.find_by(bankin_id: tag[:expense_bankin_id])
    t.save
  end
  { status: :success, imported: transactions.size }
end


class String
  def trim
    self.split("\n").map(&:strip).join("")
  end
end
