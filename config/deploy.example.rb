# frozen_string_literal: true

# config valid only for current version of Capistrano
lock "3.7.2"

set :application, "accounting"
set :repo_url,    "https://example.com/repo.git"
set :user,        "my_user"

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, -> { "/home/#{fetch(:user)}/apps/#{fetch(:application)}" }

# Default value for :scm is :git
# set :scm, :git

# Only one git clone, then git pull
set :deploy_via, :remote_cache

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push("config/database.yml", "config/secrets.yml")

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push("log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", "public/system", "public/uploads")

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# RVM setup
set :rvm_type, :user
set :rvm_ruby_version, "2.3.1"

# Bundler setup
set :bundle_without, %w(development test).join(" ")
set :bundle_flags, "--deployment --quiet --clean"
set :bundle_jobs, 4
set :bundle_binstubs, nil

# Environment PATH
set :default_environment, "PATH" => "./bin:$PATH"

# Migrations
set :conditionally_migrate, true

# Assets
set :assets_roles, [:web, :app]

# Puma
set :puma_threads,            [4, 16]
set :puma_workers,            0
set :puma_bind,               "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,              "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,                "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log,         "#{release_path}/log/puma.access.log"
set :puma_error_log,          "#{release_path}/log/puma.error.log"
set :puma_preload_app,        true
set :puma_worker_timeout,     nil
set :puma_init_active_record, true # Change to false when not using ActiveRecord

namespace :deploy do
  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke "puma:restart"
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, "cache:clear"
      # end
    end
  end
end

# Clean
after :deploy, "deploy:cleanup"
