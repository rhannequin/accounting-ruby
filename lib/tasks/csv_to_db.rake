task csv_to_db: :environment do
  puts 'Emptying database...'
  Expense.delete_all
  puts '... done.'
  filename = 'tmp/data.csv'
  expenses = []
  SmarterCSV.process(filename, {
    chunk_size: 10000,
    headers_in_file: true,
    file_encoding: 'utf-8',
    col_sep: ';',
    row_sep: "\n",
    strip_whitespace: true,
    key_mapping: { date: :date, objet: :reason, prix: :price, moyen: :way, catégories: :categories }
  }) do |array|
    array.each do |hash|
      hash.delete(:categories)
      hash[:date] = Date.strptime hash[:date], '%d/%m/%y'
      expenses << Expense.new(hash)
    end
  end
  puts 'Inserting data...'
  Expense.import expenses
  puts '... done.'
  puts Expense.count
end
