require 'sinatra/base'
require 'sinatra/reloader'
require 'active_support/all'
require 'smarter_csv'
require 'haml'
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
      data = nil
      current_money = settings.initial_money
      SmarterCSV.process('data.csv',  chunk_size: 10000,
                                      headers_in_file: true,
                                      file_encoding: 'utf-8',
                                      col_sep: ';',
                                      row_sep: "\n",
                                      strip_whitespace: true,
                                      key_mapping: {
                                        date: :date,
                                        objet: :reason,
                                        prix: :price,
                                        moyen: :way,
                                        catégories: :categories,
                                      }) do |chunk|
        data = chunk
        data.map! do |c|
          current_money += c[:price]
          c[:date] = Date.strptime(c[:date], '%d/%m/%y')
          c[:categories] = c[:categories].nil? ? [] : c[:categories].split(',').map(&:strip)
          c
        end
      end
      data = data.group_by { |x| x[:date].beginning_of_month }.sort.reverse
      data.each do |_, exps|
        exps.sort_by! { |exp| exp[:date] }.reverse!
      end
      haml :index, locals: { data: data, current_money: current_money }
    end
  end
end
