# frozen_string_literal: true

module Util
  # Parameters
  #   list: #<ActiveRecord::Relation [#<Expense>]>
  # Returns
  #   #<Hash {#<Date> => #<Float>}>
  def order_by_month(list)
    tmp = {}
    list.each do |item|
      date = item.date.beginning_of_month
      tmp[date] ||= []
      tmp[date] << item.price.to_f
    end
    tmp
  end

  # Parameters
  #   expenses: #<Hash {#<Date> => #<Float>}>
  #   categories: #<Array [#<Date>]>
  # Returns
  #   #<Hash {#<Date> => #<Float>}>
  def fill_empty_months(expenses, categories)
    tmp = {}
    categories.each do |month|
      tmp[month] = expenses.key?(month) ? expenses[month] : [0]
    end
    tmp
  end
end
