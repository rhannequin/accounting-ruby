class ExpensesService
  attr_accessor :expenses

  def initialize(expenses, debits, categories)
    tmp = order_by_month expenses
    tmp = fill_empty_months tmp, categories
    @expenses = add_debits_to_expenses tmp, debits
  end

  def data
    expenses
  end

  def get_categories
    expenses.map { |k, _| I18n.l k }
  end

  private

  def order_by_month(list)
    tmp = {}
    list.each do |item|
      date = item.date.beginning_of_month
      tmp[date] ||= []
      tmp[date] << item.price.to_f
    end
    tmp
  end

  def fill_empty_months(expenses, categories)
    tmp = {}
    categories.each do |month|
      tmp[month] = expenses.key?(month) ? expenses[month] : [0]
    end
    tmp
  end

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
