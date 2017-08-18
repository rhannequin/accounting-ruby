namespace :db do
  namespace :export do

    # bundle e rails db:export:csv
    desc 'Export data to CSV file'
    task csv: :environment do
      puts "Exporting data to CSV file"
      puts

      header = "Date;Objet;Prix;Moyen;Catégories"

      data = get_data
      data.each do |account_name, account_data|
        directory = directory_path(account_name)
        FileUtils.mkdir_p(directory) unless File.exists?(directory)
        filename = csv_filename(directory, account_name, :expenses)
        File.open(filename, 'w+') do |f|
          puts "Wrinting in #{filename}"
          f.write(account_data[:expenses].unshift(header).join("\n"))
        end
      end

      puts
      puts '... Done.'
    end

  end
end

def directory_path(account_name)
  now = Time.now.strftime("%Y%m%d%H%M%S")
  Rails.root.join('tmp', 'csv', now, account_name)
end

def csv_filename(path, account_name, type)
  database = ENV['DB_DATABASE']
  Rails.root.join(path, "#{database}_#{account_name}_#{type}.csv")
end

def get_data
  data = {}
  Account.order('expenses.date').find_each do |account|
    account_name = account.name.parameterize
    data[account_name] = { expenses: [], debits: [] }
    expenses = account.expenses.includes(:tags).order(:date)
    expenses.each do |expense|
      date = expense.date.strftime("%d/%m/%y")
      reason = expense.reason
      price = expense.price
      way = expense.way
      tags = expense.tags.map(&:name).join(',')
      data[account_name][:expenses] << "#{date};#{reason};#{price};#{way};#{tags}"
    end
  end
  data
end
