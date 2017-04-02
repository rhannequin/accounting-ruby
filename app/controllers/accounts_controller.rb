class AccountsController < ApplicationController
  include ApplicationHelper
  include ExpensesHelper

  before_action :authenticate_user!
  before_action :set_account, only: %i(edit update destroy)
  before_action :set_ignored_entities, :set_end_date, only: :show

  def index
    @accounts = current_user.accounts
                            .includes(:users, :expenses, :debits)
  end

  def show
    months_per_page = 2
    first_date = Expense.select(:date).order(:date).first.date
    @paginate = paginate_params(params[:page], first_date, months_per_page)
    end_date = get_end_day(@paginate[:current_page], months_per_page)
    start_date = get_start_day(end_date, @paginate[:current_page], months_per_page)
    range = start_date..end_date

    @account = Account.includes({ expenses: [:taggings, :tags] }, :debits)
                      .order('expenses.date DESC')
                      .find(params[:id])

    debits = get_debits(@account, start_date, end_date)

    @expenses = calculate_expenses(@account.expenses.where(date: range), @expenses_to_ignore)
    @expenses = calculate_debits(debits, @expenses, @end_date, @debits_to_ignore)
    @expenses = sort_by_month(@expenses)
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
      expenses[date][:total] += expense.price unless @expenses_to_ignore.include?(expense)
    end
    expenses
  end

  def calculate_debits(debits, expenses, end_date, debits_to_ignore)
    debits.each do |debit|
      range = (debit.start_date..(debit.end_date || end_date))
      range.to_a.map(&:beginning_of_month).uniq.each do |date|
        new_values = debit.attributes
                          .slice('reason', 'price', 'way')
                          .merge(date: date.change(day: debit.day, tags: debit.tags))
        expenses[date] ||= { expenses: [], total: 0 }
        expenses[date][:expenses] << Expense.new(new_values)
        expenses[date][:total] += debit.price unless debits_to_ignore.include?(debit)
      end
    end
    expenses
  end

  def sort_by_month(expenses)
    expenses.each do |_, arr|
      arr[:expenses].sort_by!(&:date).reverse!
    end
    expenses
  end

  def get_debits(account, start, stop)
    account.debits.end_date_after(start)
                  .start_date_before(stop)
                  .or(account.debits.end_date_nil
                                    .start_date_before(stop))
  end
end
