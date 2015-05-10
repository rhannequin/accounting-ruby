require 'sinatra/base'
require 'sinatra/reloader'
require 'logger'

module Accounting
  class App < Sinatra::Base
    set :environments, %w(production development test)
    set :environment, (ENV['RACK_ENV'] || ENV['SPACEAPI_APPLICATION_ENV'] || :development).to_sym

    configure :production do
      set :logging, Logger::INFO
    end

    configure :development do
      register Sinatra::Reloader
    end

    configure %w(development test) do
      set :logging, Logger::DEBUG
    end

    get '/' do
      '<h1>Hello World!</h1>'
    end
  end
end
