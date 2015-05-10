require 'sinatra/base'
require 'sinatra/reloader'
require 'active_support'
require 'smarter_csv'
require 'i18n'

module Accounting
  class App < Sinatra::Base
    set :environments, %w(production development test)
    set :environment, (ENV['RACK_ENV'] || ENV['SPACEAPI_APPLICATION_ENV'] || :development).to_sym

    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
      SmarterCSV.process('data.csv',  headers_in_file: true,
                                      file_encoding: 'utf-8',
                                      col_sep: ';',
                                      row_sep: "\n") do |chunk|
        chunk.each do |c|
          date = Date.strptime(c[:date], '%d/%m/%y')
        end
      end
      '<h1>Hello World!</h1>'
    end
  end
end
