module ExpensesHelper
  def get_start_day(end_day, current_page, months_per_page)
    start_day = end_day - (months_per_page - 1).month
    start_day.beginning_of_month.to_date
  end

  def get_end_day(current_page, months_per_page)
    end_day = Date.today - (months_per_page * (current_page - 1)).month
    end_day.end_of_month.to_date
  end
end
