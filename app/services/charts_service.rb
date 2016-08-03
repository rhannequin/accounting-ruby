class ChartsService
  attr_accessor :lines, :name, :months, :expenses_lb, :debits_lb

  def initialize(chart)
    @lines = chart[:lines]
    @name = chart[:name]
    @months = chart[:months]
    @expenses_lb = chart[:expenses_lb]
    @debits_lb = chart[:debits_lb]
  end

  def build_chart
    lines = []
    @lines.each do |line|
      line = LineService.new(line, months, expenses_lb, debits_lb)
      lines << line.build
    end
    new_chart(lines.first[:categories], lines)
  end

  private

  def new_chart(categories, series)
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ text: name})
      f.options[:xAxis][:categories] = categories
      series.each do |serie|
        f.series serie
      end
    end
  end
end
