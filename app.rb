require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'active_support/all'
require 'smarter_csv'
require 'haml'
require 'money'
require 'sinatra/i18n'

module Accounting
  class App < Sinatra::Base
    register Sinatra::ConfigFile

    config_file 'config.yml'

    set :environments, %w(production development test)
    set :environment, (ENV['RACK_ENV'] || ENV['ACCOUNTING_APP_ENV'] || :development).to_sym
    set :locales, Dir[File.join(settings.root, 'locales', '*.yml')]

    configure do
      register Sinatra::I18n
      I18n.locale = settings.locale
      Money.default_formatting_rules = {
        symbol_position: :after,
        thousands_separator: false,
        decimal_mark: ','
      }
    end

    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
      data = prepare_data parse_data
      current_money = calculate_current_money data, settings.start_amount
      haml :index, locals: { data: data, current_money: current_money }
    end
  end
end

def csv_options
  {
    chunk_size: 10000,
    headers_in_file: true,
    file_encoding: 'utf-8',
    col_sep: ';',
    row_sep: "\n",
    strip_whitespace: true,
    key_mapping: { date: :date, objet: :reason, prix: :price, moyen: :way, catégories: :categories }
  }
end

def parse_data
  improved = nil
  SmarterCSV.process(File.join(settings.root, 'data.csv'), csv_options) do |chunk|
    improved = improve_chunk chunk
  end
  improved
end

def improve_chunk(chunk)
  chunk.map! do |c|
    c[:date] = Date.strptime(c[:date], '%d/%m/%y')
    c[:categories] = c[:categories].nil? ? [] : c[:categories].split(',').map(&:strip)
    c
  end
end

def prepare_data(data)
  data = sort_by_date data
  data = group_by_month data
  data = add_debits data
end

def group_by_month(data)
  groups = {}
  data.each do |exp|
    (groups[exp[:date].beginning_of_month] ||= []) << exp
  end
  groups
end

def sort_by_date(data)
  data.sort_by { |exp| exp[:date] }.reverse
end

def add_debits(data)
  months_involved = data.keys.map(&:to_date).sort
  settings.debits.each do |debit|
    start_date = debit['start_date']
    end_date = debit['end_date']
    months_involved.each do |month|
      if month >= start_date && (end_date.is_a?(Date) ? month <= end_date : true)
        expense = { date: month, reason: debit['reason'], price: debit['price'], way: debit['way'], categories: (debit['categories'].nil? ? [] : debit['categories'].split(',').map(&:strip)) }
        data[month] << expense
      end
    end
  end
  data
end

def calculate_current_money(data, current_money)
  data.each do |month, expenses|
    expenses.each do |expense|
      current_money += expense[:price]
    end
  end
  current_money
end
