class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: %i(edit update destroy)

  def index
    @accounts = current_user.accounts
                            .includes(:users, :expenses, :debits)
  end

  def show
    @account = Account.includes({ expenses: [:taggings, :tags] }, :debits)
                      .order('expenses.date DESC')
                      .find(params[:id])
    expenses = @account.expenses.to_ary
    @debits = @account.debits.to_ary
    end_date = Expense.select(:date).order('date DESC').first.date
    @expenses = {}
    expenses.each do |expense|
      date = expense.date.beginning_of_month
      @expenses[date] ||= []
      @expenses[date] << expense
    end
    @debits.each do |debit|
      (debit.start_date..(debit.end_date || end_date)).to_a.map(&:beginning_of_month).uniq.each do |date|
        new_values = debit.attributes
                          .slice('reason', 'price', 'way')
                          .merge(date: date.change(day: debit.day, tags: debit.tags))
        @expenses[date] << Expense.new(new_values)
      end
    end

    # Sort expenses by date
    @expenses.each do |_, arr|
      arr.sort_by!(&:date).reverse!
    end
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
end
