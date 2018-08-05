# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails"

# Database
gem "bcrypt"
gem "pg"

# Webserver
gem "puma"

# Rack plugins
gem "rack-attack"

# Authentication
gem "devise"
gem "omniauth"
gem "omniauth-facebook"
gem "omniauth-twitter"

# Cache
gem "redis"

# Templating engine
gem "haml-rails"

# Soft-delete
gem "paranoia"

# Slugging and permalink
gem "friendly_id"

# Authorization
gem "cancancan"
gem "rolify"

# Environment configuration
gem "figaro"

# Crontab scheduler
gem 'whenever', require: false

# Assets
## Use SCSS for stylesheets
gem "sass-rails"
## Bootstrap
gem "bootstrap-sass"
## Use Uglifier as compressor for JavaScript assets
gem "uglifier"
## Use CoffeeScript for .js.coffee assets and views
gem "coffee-rails"
## See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem "mini_racer"

# Ajax
## Use jquery as the JavaScript library
gem "jquery-rails"
## Turbolinks makes following links in your web application faster
gem "turbolinks"
## Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder"
## Use respond_to and respond_with methods
gem "responders"

# Simple Form
gem "simple_form"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

gem 'smarter_csv'
gem 'activerecord-import'
gem 'bootstrap-datepicker-rails'
gem 'seed_dump'
gem 'lazy_high_charts'
gem 'yaml_db'
gem 'nokogiri'

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
end

group :development do
  gem "brakeman",              require: false # Vulnerabilities
  gem "bullet"                                # N+1 queries
  gem "capistrano",            require: false # Deployment
  gem "capistrano-bundler",    require: false # Bundler support for Capistrano
  gem "capistrano-figaro-yml", require: false # Figaro's config/application.yml support for Capistrano
  gem "capistrano-rails",      require: false # Rails support for Capistrano
  gem "capistrano-rvm",        require: false # RVM support for Capistrano
  gem "capistrano3-puma",      require: false # Puma support for Capistrano
  gem "listen"
  gem "rubocop-rails_config"                  # Ruby style guide
  gem "spring"                                # Keeps application running in the background
  gem "spring-watcher-listen"
  gem "web-console"                           # Web Console
end

group :test do
  gem "capybara"                              # Integration tests
  gem "chromedriver-helper"                   # Easy installation and use of chromedriver to run system tests with Chrome
  gem "database_cleaner"                      # Clean database during tests
  gem "factory_bot_rails"                     # Factories
  gem "faker"                                 # Use real values to fake for factories
  gem "i18n-tasks"                            # Finds and manage missing and unused translations
  gem 'nyan-cat-formatter'
  gem "rails-controller-testing"              # Support for assigns and assert_template
  gem "rspec-rails"                           # RSpec test framework
  gem "selenium-webdriver"
  gem "simplecov", require: false             # Test coverage
end
