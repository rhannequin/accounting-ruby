require 'fileutils'

desc 'Fork this starter to build a new project from it'
task :fork, :location do |_, args|
  location = args.location
  folder = to_folder_name location
  module_name = to_module_name folder
  project_string = module_name.downcase
  project_name = project_string.capitalize
  variable_string = to_variable_name folder
  project_title = to_project_title folder

  FileUtils.cp_r Dir.pwd, location

  files.each do |file|
    full_path = "#{location}/#{file}"
    nest unless File.file?(full_path)
    text = File.read full_path
    text = text.gsub(/funky-starter/, folder)
    text = text.gsub(/funky_starter/, variable_string)
    text = text.gsub(/funkystarter/, project_string)
    text = text.gsub(/Funkystarter/, project_name)
    text = text.gsub(/FunkyStarter/, module_name)
    text = text.gsub(/Funky Starter/, project_title)
    File.open(full_path, 'w') { |f| f.puts text }
  end
end

def to_folder_name(str)
  str.split('/').last.downcase
end

def to_module_name(str)
  str.split('-').map(&:capitalize).join('')
end

def to_project_title(str)
  str.split('-').map(&:capitalize).join(' ')
end

def to_variable_name(str)
  str.split('-').join('_')
end

def files
  %w(
    README.md
    install.md
    lib/tasks/fork.rake
  ) + config_files
end

def config_files
  %w( config/application.rb
      config/database.yml
      config/deploy.rb
      config/deploy.example.rb
      config/environments/production.rb
      config/initializers/session_store.rb
      config/locales/en.yml
      config/locales/fr.yml
      config/nginx.conf )
end
