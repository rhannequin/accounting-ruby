class AccountsController < ApplicationController
  include ApplicationHelper
  include ExpensesHelper

  before_action :authenticate_user!
  before_action :set_account, only: %i(edit update destroy)
  before_action :set_current_page,
                :set_first_date,
                :set_ignored_entities,
                :set_end_date,
                only: :show

  MONTHS_PER_PAGE = 2

  def index
    @accounts = current_user.accounts
                            .includes(:users, :expenses, :debits)
  end

  def show
    @paginate = paginate_params(@current_page, @first_date, MONTHS_PER_PAGE)
    end_date = get_end_day(@current_page, MONTHS_PER_PAGE)
    start_date = get_start_day(end_date, @current_page, MONTHS_PER_PAGE)
    range = start_date..end_date

    @account = Account.find(params[:id])

    expenses = @account.expenses.include_tags.where(date: range)
    debits = get_debits(@account, start_date, end_date)

    @expenses = calculate_data(expenses, @expenses_to_ignore, debits, @debits_to_ignore, range)
  end

  def new
    @account = Account.new
  end

  def edit; end

  def create
    @account = Account.new(account_params)
    @account.users << current_user
    if @account.save
      redirect_to accounts_path, notice: t(:'accounts.create.flash.success')
    else
      render :new
    end
  end

  def update
    if @account.update(account_params)
      redirect_to accounts_path, notice: t(:'accounts.update.flash.success')
    else
      render :edit
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_url, notice: t(:'accounts.destroy.flash.success')
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name)
  end

  def set_current_page
    page = params[:page]
    @current_page = page && page.to_i > 0 ? page.to_i : 1
  end

  def set_first_date
    @first_date = Expense.select(:date).order(:date).first.date
  end

  def set_ignored_entities
    ignored_tags = Tag.select(:id).ignored
    @expenses_to_ignore = Expense.with_these_tags(ignored_tags)
    @debits_to_ignore = Debit.with_these_tags(ignored_tags)
  end

  def set_end_date
    @end_date = Expense.select(:date).order('date DESC').first.date
  end

  def calculate_expenses(arr, expenses_to_ignore)
    expenses = {}
    arr.each do |expense|
      date = expense.date.beginning_of_month
      expenses[date] ||= { expenses: [], total: 0 }
      expenses[date][:expenses] << expense
      expenses[date][:total] += expense.price unless expenses_to_ignore.include?(expense)
    end
    expenses
  end

  def calculate_debits(debits, expenses, range, debits_to_ignore)
    debits.each do |debit|
      range.to_a.map(&:beginning_of_month).uniq.each do |date|
        added_debit = add_debit(debit, date, debits_to_ignore)
        expenses[date] ||= { expenses: [], total: 0 }
        expenses[date][:expenses] << added_debit[:expense]
        expenses[date][:total] += added_debit[:total]
      end
    end
    expenses
  end

  def add_debit(debit, date, debits_to_ignore)
    new_values = debit.attributes
                      .slice('reason', 'price', 'way')
                      .merge(date: date.change(day: debit.day), tags: debit.tags)
    hash = {}
    hash[:expense] = Expense.new(new_values)
    hash[:total] = debits_to_ignore.include?(debit) ? 0 : debit.price
    hash
  end

  def sort_by_month(expenses)
    expenses.each do |_, arr|
      arr[:expenses].sort_by!(&:date).reverse!
    end
    expenses
  end

  def get_debits(account, start, stop)
    account.debits
           .include_tags
           .end_date_after(start)
           .start_date_before(stop)
           .or(account.debits
                      .include_tags
                      .end_date_nil
                      .start_date_before(stop))
  end

  def calculate_data(expenses, expenses_to_ignore, debits, debits_to_ignore, range)
    data = calculate_expenses(expenses, expenses_to_ignore)
    data = calculate_debits(debits, data, range, debits_to_ignore)
    sort_by_month(data)
  end
end
