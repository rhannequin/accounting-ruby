# frozen_string_literal: true

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
