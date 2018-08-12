# frozen_string_literal: true

include Util

class ExpensesService
  attr_accessor :expenses

  def initialize(expenses, categories)
    tmp = Util.order_by_month expenses
    tmp = Util.fill_empty_months tmp, categories
    @expenses = tmp.clone
  end

  def data
    expenses
  end

  def get_categories
    expenses.map { |k, _| I18n.l k }
  end
end
