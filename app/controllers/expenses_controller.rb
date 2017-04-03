class ExpensesController < ApplicationController
  include ApplicationHelper
  include ExpensesHelper
  before_action :set_expense, only: [:edit, :update, :destroy]

  # GET /expenses
  # GET /expenses.json
  def index
    # Initiate params to get expenses
    months_per_page = 2
    ### [TODO] Temporary fix
    unless Expense.exists?
      @expenses = []
      @current_amount = 0
      @paginate = { current_page: 1, total_pages: 0 }
      return
    end
    ### Temporary fix
    first_date = Expense.select(:date).order(:date).first.date
    page = params[:page]
    current_page = page && page.to_i > 0 ? page.to_i : 1
    @paginate = paginate_params(current_page, first_date, months_per_page)
    end_date = get_end_day(current_page, months_per_page)
    start_date = get_start_day(end_date, current_page, months_per_page)
    range = start_date..end_date

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

    # Add debits to each month and calculate current_amount
    @current_amount = Expense.select(:price).map(&:price).sum
    all_months = (first_date..Date.today).to_a.map { |d| d.beginning_of_month }.uniq
    debits_to_ignore = Debit.with_these_tags ignored_tags
    Debit.include_tags.find_each do |debit|
      all_months.each do |month|
        beginning_of_month = month.beginning_of_month
        if debit.applies_this_month?(month)
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
    @expense = Expense.include_tags.find(params[:id])
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
