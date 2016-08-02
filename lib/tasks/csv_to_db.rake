require 'yaml'

task csv_to_db: :environment do
  puts 'Emptying database...'
  Expense.delete_all
  Debit.delete_all
  Tagging.delete_all
  Tag.delete_all
  puts '... done.'
  expenses_file = 'tmp/data.csv'
  expenses = []
  tags = []

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
      expense_tags = hash[:tags].split(',').map do |t|
        tag = { name: t.strip }
        tags << tag unless tags.include? tag
        tag
      end
      hash.delete(:tags)
      expense = Expense.new(hash)
      expense_tags.each { |t| expense.tags.build t }
      expenses << expense
    end
  end

  puts 'Inserting tags...'
  Tag.import tags.map { |t| Tag.new t }
  puts "... done. (#{Tag.count})"
  puts

  puts 'Inserting expenses...'
  Expense.import expenses
  ActiveRecord::Base.transaction do
    expenses.each do |expense|
      e = Expense.where(reason: expense.reason, date: expense.date, price: expense.price, way: expense.way).take
      e.tags << expense.tags.map { |t| Tag.where(name: t.name).take }
      e.save
    end
  end
  puts "... done. (#{Expense.count})"
  puts

  puts 'Inserting debits...'
  debits = YAML.load_file('tmp/config.yml')['debits']
  debits.each do |debit|
    unless debit['categories'].nil?
      debit_tags = debit['categories'].split(&:strip).map { |c| Tag.find_or_create_by(name: c) }
    end
    debit.delete('categories')
    d = Debit.create(debit)
    if debit_tags
      d.tags = debit_tags
      d.save
    end
  end
  puts "... done. (#{Debit.count})"
end
