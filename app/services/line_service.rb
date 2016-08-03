class LineService
  attr_accessor :type, :name, :covers, :months, :expenses_lb, :debits_lb,
                :expenses, :debits, :data, :categories

  def initialize(line, months, expenses_lb, debits_lb)
    @type = line[:type]
    @name = line[:name]
    @covers = line[:covers]
    @months = months
    @expenses_lb = expenses_lb
    @debits_lb = debits_lb
    init
  end

  def build
    @data = calculate_figures expenses.data, months, type
    @categories = expenses.get_categories.last(months)
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
    until_date = (Date.today - covers.month).beginning_of_month
    @debits = debits_lb.call(until_date)
    @expenses = ExpensesService.new expenses_lb.call(until_date), @debits
  end

  def calculate_figures(expenses, months, type)
    values = expenses.map { |_, v| v.sum.round(2) * (-1) }
    case type
    when :curve then values.last(months)
    when :average then array_of_average(values, months)
    end
  end

  def array_of_average(values, months)
    size = values.size
    Array.new(size, calculate_average(values, size)).last(months)
  end

  def calculate_average(values, size)
    (values.sum / size).round
  end

  def get_categories(expenses)
    expenses.map { |k, _| I18n.l k }
  end
end
