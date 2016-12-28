include Util

class ExpensesService
  attr_accessor :expenses

  def initialize(expenses, debits, categories)
    tmp = Util.order_by_month expenses
    tmp = Util.fill_empty_months tmp, categories
    @expenses = add_debits_to_expenses tmp, debits
  end

  def data
    expenses
  end

  def get_categories
    expenses.map { |k, _| I18n.l k }
  end

  private

  def add_debits_to_expenses(expenses, debits)
    today = Date.today
    tmp = expenses.clone
    expenses.map do |k, _|
      debits.each do |debit|
        range = (debit.start_date..(debit.end_date || today))
        if range.include?(k)
          tmp[k] << debit.price.to_f
        end
      end
    end
    tmp
  end
end
