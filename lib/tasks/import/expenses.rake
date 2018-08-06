# frozen_string_literal: true

require "nokogiri"
require "date"
require "yaml"
require "pp"


namespace :import do
  task expenses: :environment do
    start_time = Time.now
    puts
    puts "== Start importing task at #{start_time} =="
    puts
    process_loop
    end_time = Time.now
    puts
    puts "== End importing task at #{end_time} (#{(end_time - start_time).round(2)} seconds) =="
    puts
  end
end


def process_loop
  config = YAML.load_file(Rails.root.join("lib", "tasks", "import", "expenses_config.yml"))
  config.fetch("accounts").each do |account|
    account_name = account.fetch("name")
    puts
    puts "== Start importing expenses from #{account_name} =="
    result = process_import(account)
    puts "== End importing expenses from #{account_name} =="
    puts "== Imported #{result[:imported]} transactions =="
    puts
  end
end


def process_import(account)
  filename = Rails.root.join("tmp", "expenses", account.fetch("file"))
  doc = File.open(filename) { |f| Nokogiri::HTML(f, nil, Encoding::UTF_8.to_s) }
  transactions = doc.css("ul.transactionList li")
  transactions.each do |entry|
    next if entry.attr("id").nil?
    expense = ExpenseParser.new(entry).parse
    # puts expense.show #if account.fetch("ignored").map { |ign| expense.name.include?(ign) }.include?(true)
  end
  { status: :success, imported: transactions.size }
end


class String
  def trim
    self.split("\n").map(&:strip).join("")
  end
end

class FrenchDateParser
  attr_accessor :french_date

  def initialize(str)
    @french_date = str
  end

  def parse
    remove_day_name
    replace_month_name
    to_date
  end

  private

    def remove_day_name
      french_date.gsub!("lundi", "")
      french_date.gsub!("mardi", "")
      french_date.gsub!("mercredi", "")
      french_date.gsub!("jeudi", "")
      french_date.gsub!("vendredi", "")
      french_date.gsub!("samedi", "")
      french_date.gsub!("dimanche", "")
      french_date
    end

    def replace_month_name
      french_date.gsub!("janv.", "january")
      french_date.gsub!("févr.", "february")
      french_date.gsub!("mars", "march")
      french_date.gsub!("avr.", "april")
      french_date.gsub!("mai", "may")
      french_date.gsub!("juin", "june")
      french_date.gsub!("juil.", "july")
      french_date.gsub!("août", "august")
      french_date.gsub!("sept.", "september")
      french_date.gsub!("oct.", "october")
      french_date.gsub!("nov.", "november")
      french_date.gsub!("déc.", "december")
      french_date
    end

    def to_date
      return Date.today if french_date == "Aujourd'hui"
      Date.parse(french_date.strip)
    end
end

class ExpenseParser
  attr_accessor :entry, :attr

  def initialize(entry)
    @entry = entry
    @attr = {}
  end

  def parse
    parse_bankin_id
    parse_date
    parse_name
    parse_category
    parse_price
    Expense.new(attr)
  end

  private

    def parse_bankin_id
      @attr[:bankin_id] = entry.attr("id").split("_").last
    end

    def parse_date
      @attr[:date] = FrenchDateParser.new(entry.css("div.headerDate").last.text.trim).parse
    end

    def parse_name
      @attr[:name] = entry.css("div.dtb").last.css(".dbl")[1].text.trim
    end

    def parse_category
      @attr[:category] = entry.css("div.dtb").last.css(".dbl").last.text.trim
    end

    def parse_price
      @attr[:price] = entry.css("div.dtc").last.content.trim
    end
end

class Expense
  attr_accessor :bankin_id, :date, :name, :category, :price

  def initialize(args)
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def show
    "#{bankin_id}: #{date.strftime("%d/%m/%Y")} #{name} (#{category}) > #{price}"
  end
end
