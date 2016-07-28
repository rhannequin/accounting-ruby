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

    # Order expenses by month
    tmp = {}
    @expenses.each do |expense|
      date = expense.date.beginning_of_month
      tmp[date] ||= { expenses: [], total: 0 }
      tmp[date][:expenses] << expense
      tmp[date][:total] += expense.price if expense.price > 0
    end
    @expenses = tmp

    # Add debits to each month and calculate currnt_amount
    @current_amount = Expense.select(:price).map(&:price).sum
    all_months = (first_date..Date.today).to_a.map { |d| d.beginning_of_month }.uniq
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
    data = {
      period: { months: 6 },
      global: { months: 12 }
    }
    ignore_tag = Tag.select(:id).where(name: 'ignore').take

    data.each do |key, value|
      until_date = (Date.today - (value[:months] - 1).month).beginning_of_month
      expenses = Expense.joins(:taggings)
                        .where(['date > ?', until_date])
                        .where.not(taggings: { tag_id: ignore_tag.id })
      tmp = {}
      expenses.each do |expense|
        date = expense.date.beginning_of_month
        tmp[date] ||= []
        tmp[date] << expense.price.to_f unless expense.tags.include?(ignore_tag)
      end
      values = tmp.map { |_, v| v.sum.round * (-1) }
      data[key][:categories] = tmp.map { |k, _| I18n.l k }
      data[key][:values] = values
      data[key][:average] = values.sum / values.size
    end

    @chart_global = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ text: 'Dépenses globales'})
      f.options[:xAxis][:categories] = data[:period][:categories]
      f.series(type: 'spline', name: 'Dépenses mensuelles', data: data[:period][:values])
      f.series(type: 'spline', name: 'Moyenne sur 6 mois', data: Array.new(data[:period][:months], data[:period][:average]))
      f.series(type: 'spline', name: 'Moyenne totale 1 an', data: Array.new(data[:period][:months], data[:global][:average]))
    end



    data = {
      period: { months: 6 },
      global: { months: 12 }
    }
    ignore_tag = Tag.select(:id).where(name: 'ignore').take
    lunch_tag = Tag.select(:id).where(name: 'lunch').take

    data.each do |key, value|
      until_date = (Date.today - (value[:months] - 1).month).beginning_of_month
      expenses = Expense.joins(:taggings)
                        .where(['date > ?', until_date])
                        .where.not(taggings: { tag_id: ignore_tag.id })
                        .where(taggings: { tag_id: lunch_tag.id })
      tmp = {}
      expenses.each do |expense|
        date = expense.date.beginning_of_month
        tmp[date] ||= []
        tmp[date] << expense.price.to_f unless expense.tags.include?(ignore_tag)
      end
      values = tmp.map { |_, v| v.sum.round * (-1) }
      data[key][:categories] = tmp.map { |k, _| I18n.l k }
      data[key][:values] = values
      data[key][:average] = values.sum / values.size
    end

    @chart_lunch = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ text: 'Dépenses déjeuner'})
      f.options[:xAxis][:categories] = data[:period][:categories]
      f.series(type: 'spline', name: 'Dépenses mensuelles', data: data[:period][:values])
      f.series(type: 'spline', name: 'Moyenne sur 6 mois', data: Array.new(data[:period][:months], data[:period][:average]))
      f.series(type: 'spline', name: 'Moyenne totale 1 an', data: Array.new(data[:period][:months], data[:global][:average]))
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
end
