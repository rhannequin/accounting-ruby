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

    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
      data = nil
      SmarterCSV.process('data.csv',  chunk_size: 10000,
                                      headers_in_file: true,
                                      file_encoding: 'utf-8',
                                      col_sep: ';',
                                      row_sep: "\n",
                                      remove_empty_values: false,
                                      remove_zero_values: false,
                                      remove_unmapped_keys: false,
                                      remove_empty_hashes: false,
                                      strip_whitespace: true,
                                      key_mapping: {
                                        date: :date,
                                        objet: :object,
                                        prix: :price,
                                        moyen: :way,
                                        catégories: :categories,
                                      }) do |chunk|
        data = chunk
        data.map! do |c|
          c[:date] = Date.strptime(c[:date], '%d/%m/%y')
          c[:categories] = c[:categories].split(',').map(&:strip) unless c[:categories].nil?
          c
        end
      end
      data = data.group_by { |x| x[:date].beginning_of_month }.sort.reverse
      haml :index, locals: { data: data }
    end
  end
end
