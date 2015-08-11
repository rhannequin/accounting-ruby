require_relative 'init'

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
      statistics = get_statistics data
      current_money = calculate_current_money data, settings.start_amount
      haml :index, locals: {
        data: data,
        current_money: current_money,
        statistics: statistics,
        tabs: tabs
      }
    end
  end
end

require_relative 'helpers/init'
