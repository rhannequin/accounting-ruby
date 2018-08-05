# frozen_string_literal: true

module ApplicationHelper
  def alert_class(name)
    name = name.to_sym
    case name
    when :notice, :success then :success
    when :warning then :warning
    when :info then :info
    else :danger
    end
  end

  def safe_unescape(str)
    safe_join [raw(str)]
  end

  def empty_char
    safe_unescape "&#8709;"
  end

  def provider_profile_link(provider, uid)
    case provider
    when "twitter"
      link_to provider.capitalize, "https://twitter.com/intent/user?user_id=#{uid}"
    when "facebook"
      link_to provider.capitalize, "https://www.facebook.com/#{uid}"
    else
      empty_char
    end
  end

  def roles_list(roles)
    roles.any? ? roles.map(&:name).join(", ") : empty_char
  end

  def active_class(path)
    if path.is_a?(Array)
      "active" if path.map { |p| current_page?(p) }.include?(true)
    elsif current_page?(path)
      "active"
    end
  end

  def paginate_params(current_page, first_date, months_per_page)
    @paginate = {
      current_page: current_page,
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
