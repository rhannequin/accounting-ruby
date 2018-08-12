# frozen_string_literal: true

class ChartsService
  attr_accessor :lines, :name, :months, :expenses_lb

  def initialize(chart)
    @lines = chart[:lines]
    @name = chart[:name]
    @months = chart[:months]
    @account = chart[:account]
    @expenses_lb = chart[:expenses_lb]
  end

  def build_chart
    lines = []
    @lines.each do |line|
      line = LineService.new(line, months, @account, expenses_lb)
      lines << line.build.publish
    end
    new_chart(lines.first[:categories], lines)
  end

  private

    def new_chart(categories, series)
      LazyHighCharts::HighChart.new("graph") do |f|
        f.title text: name
        f.options[:xAxis][:categories] = categories
        series.each do |serie|
          f.series serie
        end
      end
    end
end
