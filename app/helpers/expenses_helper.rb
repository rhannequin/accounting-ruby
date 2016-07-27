module ExpensesHelper
  def currency(dec)
    "#{'%.2f' % dec}€"
  end

  def expenses_pagination(current_page, months_per_page)
    end_date = Date.today - (months_per_page * (current_page - 1)).month
    start_date = end_date - (months_per_page - 1).month
    start_paginate = start_date.beginning_of_month.to_date
    end_paginate = end_date.end_of_month.to_date
    range = start_paginate..end_paginate
  end
end
