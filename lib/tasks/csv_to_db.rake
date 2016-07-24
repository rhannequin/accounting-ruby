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
    key_mapping: { date: :date, objet: :reason, prix: :price, moyen: :way, catégories: :tag_list }
  }) do |array|
    array.each do |hash|
      hash[:date] = Date.strptime hash[:date], '%d/%m/%y'
      expenses << Expense.new(hash)
    end
  end
  puts 'Inserting expenses...'
  Expense.import expenses
  expenses.each do |expense|
    e = Expense.where(reason: expense.reason, date: expense.date, price: expense.price, way: expense.way).take
    e.tag_list.add *expense.tag_list
    e.save
  end
  puts "... done. (#{Expense.count})"
  puts
  puts 'Inserting debits...'
  debits = YAML.load_file('tmp/config.yml')['debits']
  data = []
  debits.each do |debit|
    debit[:tag_list] = debit.delete('categories')
    Debit.create(debit)
  end
  puts "... done. (#{Debit.count})"
end
