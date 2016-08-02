class ExpensesController < ApplicationController
  include ApplicationHelper
  include ExpensesHelper
  before_action :set_expense, only: [:edit, :update, :destroy]

  # GET /expenses
  # GET /expenses.json
  def index
    # Initiate params to get expenses
    months_per_page = 2
    first_date = Expense.select(:date).order(:date).first.date
    @paginate = paginate_params(params[:page], first_date, months_per_page)
    range = expenses_pagination(@paginate[:current_page], months_per_page)

    @expenses = Expense.all_ordered.where(date: range)
    ignored_tags = Tag.select(:id).ignored
    expenses_to_ignore = Expense.with_these_tags ignored_tags

    # Order expenses by month
    tmp = {}
    @expenses.each do |expense|
      date = expense.date.beginning_of_month
      tmp[date] ||= { expenses: [], total: 0 }
      tmp[date][:expenses] << expense
      tmp[date][:total] += expense.price unless expenses_to_ignore.include?(expense)
    end
    @expenses = tmp

    # Add debits to each month and calculate currnt_amount
    @current_amount = Expense.select(:price).map(&:price).sum
    all_months = (first_date..Date.today).to_a.map { |d| d.beginning_of_month }.uniq
    debits_to_ignore = Debit.with_these_tags ignored_tags
    Debit.with_tags.find_each do |debit|
      all_months.each do |month|
        beginning_of_month = month.beginning_of_month
        cond = (
          (beginning_of_month..month.end_of_month).cover?(debit.start_date) ||
          (beginning_of_month..month.end_of_month).cover?(debit.end_date)
        ) || (debit.start_date < month && (debit.end_date ? debit.end_date > month : true))
        if cond
          @current_amount += debit.price
          if range.cover?(month)
            @expenses[beginning_of_month] ||= { expenses: [], total: 0 }
            @expenses[beginning_of_month][:total] += debit.price unless debits_to_ignore.include?(debit)
            new_values = debit.attributes
                              .slice('reason', 'price', 'way')
                              .merge({ date: month.change(day: debit.day), tags: debit.tags })
            @expenses[beginning_of_month][:expenses] << Expense.new(new_values)
          end
        end
      end
    end
    start_amount = 0
    @current_amount += start_amount

    # Sort expenses by date
    @expenses.each do |month, arr|
      arr[:expenses].sort_by!(&:date).reverse!
    end
  end

  # GET /expenses/1
  # GET /expenses/1.json
  def show
    @expense = Expense.with_tags.find(params[:id])
  end

  # GET /expenses/new
  def new
    @expense = Expense.new
  end

  # GET /expenses/1/edit
  def edit
  end

  # POST /expenses
  # POST /expenses.json
  def create
    params = expense_params
    tags = params['tag_ids']
    params.delete('tag_ids')
    @expense = Expense.new(params)

    respond_to do |format|
      if @expense.save && (@expense.tag_ids = tags)
        format.html { redirect_to @expense, notice: t(:'expenses.create.flash.success') }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expenses/1
  # PATCH/PUT /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to @expense, notice: t(:'expenses.update.flash.success') }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1
  # DELETE /expenses/1.json
  def destroy
    @expense.destroy
    respond_to do |format|
      format.html { redirect_to expenses_url, notice: t(:'expenses.destroy.flash.success') }
      format.json { head :no_content }
    end
  end

  def test
    @charts = []

    ignore_tag_ids = Tag.select(:id).ignored
    lunch_tag_id = Tag.select(:id).find_by(name: 'lunch').id

    charts = [
      {
        lines: [
          { type: :curve, name: 'Dépenses mensuelles', covers: 6 },
          { type: :average, name: 'Moyenne sur 6 mois', covers: 6 },
          { type: :average, name: 'Moyenne sur 1 an', covers: 12 },
        ],
        name: 'Dépenses mensuelles',
        months: 6,
        expenses_lb: -> (u) { Expense.where(['date > ?', u])
                                     .where.not(
                                        id: Expense.with_these_tags(ignore_tag_ids)
                                      ) },
        debits_lb: -> (u) { Debit.where(['end_date > ?', u])
                                 .or(Debit.where(end_date: nil))
                                 .where(['start_date < ?', Date.today])
                                 .where.not(
                                    id: Debit.with_these_tags(ignore_tag_ids)
                                 ) }
      }, {
        lines: [
          { type: :curve, name: 'Dépenses mensuelles', covers: 6 },
          { type: :average, name: 'Moyenne sur 6 mois', covers: 6 },
          { type: :average, name: 'Moyenne sur 1 an', covers: 12 },
        ],
        name: 'Dépenses mensuelles',
        months: 6,
        expenses_lb: -> (u) { Expense.includes(:taggings)
                                     .where(['date > ?', u])
                                     .where(taggings: { tag_id: lunch_tag_id })
                                     .where.not(
                                        id: Expense.joins(:taggings)
                                                   .where(taggings: { tag_id: ignore_tag_ids })
                                      ) },
        debits_lb: -> (u) { Debit.where(['end_date > ?', u])
                                 .or(Debit.where(end_date: nil))
                                 .where(['start_date < ?', Date.today]) }
      }
    ]

    @charts = charts.map do |chart|
      build_chart chart
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expense_params
      params.require(:expense).permit(:date, :reason, :price, :way, tag_ids: [])
    end

    def order_by_month(list)
      tmp = {}
      list.each do |item|
        date = item.date.beginning_of_month
        tmp[date] ||= []
        tmp[date] << item.price.to_f
      end
      tmp
    end

    def build_chart(chart)
      lines = []
      chart[:lines].each do |line|
        lines << build_line(line, chart[:months], chart[:expenses_lb], chart[:debits_lb])
      end
      new_chart(chart[:name], lines.first[:categories], lines)
    end

    def build_line(line, months, e_lb, d_lb)
      until_date = (Date.today - (line[:covers]).month).beginning_of_month
      expenses = order_by_month e_lb.call(until_date)
      debits = d_lb.call(until_date)
      expenses = add_debits_to_expenses(expenses, debits)
      {
        type: 'spline',
        name: line[:name],
        data: calculate_figures(expenses, months, line[:type]),
        categories: get_categories(expenses)
      }
    end

    def add_debits_to_expenses(expenses, debits)
      today = Date.today
      tmp = expenses.clone
      expenses.map do |k, _|
        debits.each do |debit|
          range = (debit.start_date..(debit.end_date || today))
          if range.include?(k)
            tmp[k] << debit.price.to_f
          end
        end
      end
      tmp
    end

    def calculate_figures(expenses, months, type)
      values = expenses.map { |_, v| v.sum.round(2) * (-1) }.last(months)
      case type
      when :curve then values
      when :average then array_of_average(values)
      end
    end

    def get_categories(expenses)
      expenses.map { |k, _| I18n.l k }
    end

    def array_of_average(values)
      size = values.size
      Array.new(size, calculate_average(values, size))
    end

    def calculate_average(values, size)
      (values.sum / size).round
    end

    def new_chart(title, categories, series)
      LazyHighCharts::HighChart.new('graph') do |f|
        f.title({ text: title})
        f.options[:xAxis][:categories] = categories
        series.each do |serie|
          f.series serie
        end
      end
    end
end
