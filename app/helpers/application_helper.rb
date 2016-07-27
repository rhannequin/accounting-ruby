module ApplicationHelper
  def paginate_params(current_page, first_date, months_per_page)
    today = Date.today
    current_page = 1 unless current_page && current_page.to_i > 0
    @paginate = {
      current_page: current_page.to_i,
      total_pages: paginate_total_pages(first_date, months_per_page)
    }
  end

  def paginate_total_pages(first_date, months_per_page)
    today = Date.today
    today_month_number = today.year * 12 + today.month
    first_date_month_number = first_date.year * 12 + first_date.month
    total_months = today_month_number - first_date_month_number + 1
    (total_months.to_f / months_per_page.to_f).ceil
  end
end
