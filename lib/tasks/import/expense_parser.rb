# frozen_string_literal: true

require_relative "french_date_parser"

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
    { bankin_id: attr[:bankin_id],
      date: attr[:date],
      reason: attr[:name],
      price: attr[:price],
      tag: attr[:category]
    }
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
      @attr[:price] = entry.css("div.dtc")
                           .last
                           .content
                           .trim
                           .split('€')
                           .first
                           .strip
                           .gsub(',', '.')
                           .gsub(/\A[[:space:]]+/, '')
      is_negative = @attr[:price].include?("-")
      @attr[:price] = @attr[:price].split('.')
                                   .map { |s| s.tr('^0-9', '') }
                                   .join('.')
                                   .to_f
      @attr[:price] = @attr[:price] * -1 if is_negative
    end
end
