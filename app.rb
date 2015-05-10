require 'sinatra/base'
require 'sinatra/reloader'

module Accounting
  class App < Sinatra::Base
    set :environments, %w(production development test)
    set :environment, (ENV['RACK_ENV'] || ENV['SPACEAPI_APPLICATION_ENV'] || :development).to_sym

    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
      '<h1>Hello World!</h1>'
    end
  end
end
