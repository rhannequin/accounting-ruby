require 'sinatra/base'
require 'sinatra/reloader'
require 'active_support/all'
require 'smarter_csv'
require 'haml'
require 'money'
require 'i18n'

module Accounting
  class App < Sinatra::Base
    set :environments, %w(production development test)
    set :environment, (ENV['RACK_ENV'] || ENV['SPACEAPI_APPLICATION_ENV'] || :development).to_sym
    set :initial_money, 100

    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
      parsed = parse_data settings.initial_money
      data = prepare_data parsed[:data]
      haml :index, locals: { data: data, current_money: parsed[:current_money] }
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

def parse_data(current_money)
  improved = nil
  SmarterCSV.process('data.csv',  csv_options) do |chunk|
    improved = improve_chunk(chunk, current_money)
  end
  {
    data: improved[:chunk],
    current_money: improved[:current_money]
  }
end

def improve_chunk(chunk, current_money)
  chunk.map! do |c|
    current_money += c[:price]
    c[:date] = Date.strptime(c[:date], '%d/%m/%y')
    c[:categories] = c[:categories].nil? ? [] : c[:categories].split(',').map(&:strip)
    c
  end
  {
    chunk: chunk,
    current_money: current_money
  }
end

def prepare_data(data)
  sort_by_date group_by_month(data)
end

def group_by_month(data)
  data.group_by { |x| x[:date].beginning_of_month }.sort.reverse
end

def sort_by_date(data)
  data.each do |_, exps|
    exps.sort_by! { |exp| exp[:date] }.reverse!
  end
end
