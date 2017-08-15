class LineService
  attr_accessor :type, :name, :covers, :months, :expenses_lb, :debits_lb,
                :expenses, :debits, :data, :categories

  def initialize(line, months, account, expenses_lb, debits_lb)
    @type = line[:type]
    @name = line[:name]
    @covers = line[:covers]
    @months = months
    @account = account
    @expenses_lb = expenses_lb
    @debits_lb = debits_lb
    init
  end

  def build
    @data = calculate_figures(expenses.data, type).last(months)
    @categories = @categories.last(months).map { |c| I18n.l(c, format: :year_and_month).capitalize }
    self
  end

  def publish
    {
      type: 'spline',
      name: name,
      data: data,
      categories: categories
    }
  end

  private

  def init
    today = Date.today
    past_date = covers.nil? ? @account.expenses.order(:date).first.date : today - covers.month
    until_date = past_date.beginning_of_month
    @categories = (past_date..today).to_a.map { |d| d.beginning_of_month }.uniq
    @debits = debits_lb.call(until_date)
    @expenses = ExpensesService.new expenses_lb.call(until_date), @debits, @categories
  end

  def calculate_figures(expenses, type)
    values = expenses.map { |_, v| v.sum.round(2) * (-1) }
    case type
    when :curve then values
    when :average then array_of_average(values)
    end
  end

  def array_of_average(values)
    size = values.size
    Array.new(size, calculate_average(values, size))
  end

  def calculate_average(values, size)
    (values.sum / size).round
  end
end
