require 'yaml'

task csv_to_db: :environment do
  puts 'Emptying database...'
  Expense.delete_all
  Debit.delete_all
  puts '... done.'
  expenses_file = 'tmp/data.csv'
  expenses = []

  SmarterCSV.process(expenses_file, {
    chunk_size: 10000,
    headers_in_file: true,
    file_encoding: 'utf-8',
    col_sep: ';',
    row_sep: "\n",
    strip_whitespace: true,
    key_mapping: { date: :date, objet: :reason, prix: :price, moyen: :way, catégories: :tags }
  }) do |array|
    array.each do |hash|
      hash[:date] = Date.strptime hash[:date], '%d/%m/%y'
      hash[:tags] ||= ''
      tags = hash[:tags].split(',').map { |t| { name: t.strip } }
      hash.delete(:tags)
      expense = Expense.new(hash)
      tags.each { |t| expense.tags.build t }
      expenses << expense
    end
  end

  puts 'Inserting expenses...'
  Expense.import expenses
  ActiveRecord::Base.transaction do
    expenses.each do |expense|
      e = Expense.where(reason: expense.reason, date: expense.date, price: expense.price, way: expense.way).take
      e.tags << expense.tags
      e.save
    end
  end
  puts "... done. (#{Expense.count})"
  puts

  puts 'Inserting debits...'
  debits = YAML.load_file('tmp/config.yml')['debits']
  data = []
  debits.each do |debit|
    tags = debit['categories'].split(&:strip).map { |c| Tag.new(name: c) } unless debit['categories'].nil?
    debit.delete('categories')
    d = Debit.create(debit)
    if tags
      d.tags = tags
      d.save
    end
  end
  puts "... done. (#{Debit.count})"
end
