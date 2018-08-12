# frozen_string_literal: true

module ExpensesHelper
  def get_start_day(end_day, months_per_page)
    start_day = end_day - (months_per_page - 1).month
    start_day.beginning_of_month.to_date
  end

  def get_end_day(current_page, months_per_page)
    end_day = Date.today - (months_per_page * (current_page - 1)).month
    end_day.end_of_month.to_date
  end

  def calculate_expenses(arr, expenses_to_ignore)
    expenses = {}
    arr.each do |expense|
      date = expense.date.beginning_of_month
      expenses[date] ||= { expenses: [], total: 0 }
      expenses[date][:expenses] << expense
      expenses[date][:total] += expense.price unless expenses_to_ignore.include?(expense)
    end
    expenses
  end

  def sort_by_month(expenses)
    expenses.each do |_, arr|
      arr[:expenses].sort_by!(&:date).reverse!
    end
    expenses
  end

  def calculate_data(expenses, expenses_to_ignore, range)
    data = calculate_expenses(expenses, expenses_to_ignore)
    sort_by_month(data)
  end
end
