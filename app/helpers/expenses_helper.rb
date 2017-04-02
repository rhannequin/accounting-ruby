module ExpensesHelper
  def get_start_day(end_day, current_page, months_per_page)
    end_day - (months_per_page - 1).month
  end

  def get_end_day(current_page, months_per_page)
    Date.today - (months_per_page * (current_page - 1)).month
  end

  def expenses_pagination(start_day, end_day)
    start_paginate = start_day.beginning_of_month.to_date
    end_paginate = end_day.end_of_month.to_date
    range = start_paginate..end_paginate
  end
end
