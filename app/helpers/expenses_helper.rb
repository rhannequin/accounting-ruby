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

  def calculate_debits(debits, expenses, range, debits_to_ignore)
    debits.each do |debit|
      range.to_a.map(&:beginning_of_month).uniq.each do |date|
        added_debit = add_debit(debit, date, debits_to_ignore)
        expenses[date] ||= { expenses: [], total: 0 }
        expenses[date][:expenses] << added_debit[:expense]
        expenses[date][:total] += added_debit[:total]
      end
    end
    expenses
  end

  def add_debit(debit, date, debits_to_ignore)
    new_values = debit.attributes
                      .slice("reason", "price", "way")
                      .merge(date: date.change(day: debit.day), tags: debit.tags)
    hash = {}
    hash[:expense] = Expense.new(new_values)
    hash[:total] = debits_to_ignore.include?(debit) ? 0 : debit.price
    hash
  end

  def sort_by_month(expenses)
    expenses.each do |_, arr|
      arr[:expenses].sort_by!(&:date).reverse!
    end
    expenses
  end

  def get_debits(account, start, stop)
    account.debits
           .include_tags
           .end_date_after(start)
           .start_date_before(stop)
           .or(account.debits
                      .include_tags
                      .end_date_nil
                      .start_date_before(stop))
  end

  def calculate_data(expenses, expenses_to_ignore, debits, debits_to_ignore, range)
    data = calculate_expenses(expenses, expenses_to_ignore)
    data = calculate_debits(debits, data, range, debits_to_ignore)
    sort_by_month(data)
  end
end
