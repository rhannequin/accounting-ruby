# frozen_string_literal: true

require "nokogiri"
require "date"
require "pp"


namespace :import do
  task expenses: :environment do
    bnp_commun = Rails.root.join("tmp", "expenses", "bnp-commun.html")
    doc = File.open(bnp_commun) { |f| Nokogiri::HTML(f, nil, Encoding::UTF_8.to_s) }
    doc.css("ul.transactionList li").each do |entry|
      next if entry.attr("id").nil?
      bankin_id = entry.attr("id").split("_").last
      date = FrenchDateParser.new(entry.css("div.headerDate").last.text.trim).parse
      name = entry.css("div.dtb").last.css(".dbl")[1].text.trim
      category = entry.css("div.dtb").last.css(".dbl").last.text.trim
      price = entry.css("div.dtc").last.content.trim
      expense = Expense.new(bankin_id, date, name, category, price)
      puts expense.show
    end
  end
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
      Date.parse(french_date.strip)
    end
end

class Expense
  attr_accessor :bankin_id, :date, :name, :category, :price

  def initialize(bankin_id, date, name, category, price)
    @bankin_id = bankin_id
    @date = date
    @name = name
    @category = category
    @price = price
  end

  def show
    "#{bankin_id}: #{date.strftime("%d/%m/%Y")} #{name} (#{category}) > #{price}"
  end
end
