namespace :db do
  namespace :dump do

    # bundle e rails db:dump:export
    desc 'Dump all database'
    task export: :environment do
      now = Time.now.strftime("%Y%m%dT%H%M")
      host = ENV['DB_HOST']
      port = ENV['DB_PORT']
      database = ENV['DB_DATABASE']
      user = ENV['DB_USERNAME']
      dump_path = Rails.root.join('tmp', 'dumps', "dump_#{database}_#{now}.sql")
      puts "Dumping database #{database} to #{dump_path} ..."
      system("pg_dump --clean -h #{host} -p #{port} -d #{database} -U #{user} > #{dump_path}")
      puts '... Done.'
    end


    # DUMP_FILE=/path/to/dump bundle e rails db:dump:import
    desc 'Import dump file'
    task import: :environment do
      host = ENV['DB_HOST']
      port = ENV['DB_PORT']
      database = ENV['DB_DATABASE']
      user = ENV['DB_USERNAME']
      dump = ENV['DUMP_FILE']
      puts "Importing database #{dump} to #{database} ..."
      puts
      system("psql -h #{host} -p #{port} -d #{database} -U #{user} < #{dump}")
      puts
      puts '... Done.'
    end


    # bundle e rails db:dump:email
    desc 'Email dump file'
    task email: :environment do
      last_dump = Dir[Rails.root.join('tmp', 'dumps', 'dump_*.sql')].sort.reverse.first
      to = ENV['DUMP_EMAIL_RECEIVER']
      puts "Sending #{last_dump} to #{to} ..."
      DumpMailer.dump_email(to, last_dump).deliver_now
      puts '... Done.'
    end

  end
end
