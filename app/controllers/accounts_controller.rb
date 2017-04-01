class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: %i(edit update destroy)
  before_action :set_ignored_entities, only: :show

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
      @expenses[date] ||= { expenses: [], total: 0 }
      @expenses[date][:expenses] << expense
      @expenses[date][:total] += expense.price unless @expenses_to_ignore.include?(expense)
    end
    @debits.each do |debit|
      (debit.start_date..(debit.end_date || end_date)).to_a.map(&:beginning_of_month).uniq.each do |date|
        new_values = debit.attributes
                          .slice('reason', 'price', 'way')
                          .merge(date: date.change(day: debit.day, tags: debit.tags))
        @expenses[date][:expenses] << Expense.new(new_values)
        @expenses[date][:total] += debit.price unless @debits_to_ignore.include?(debit)
      end
    end

    # Sort expenses by date
    @expenses.each do |_, arr|
      arr[:expenses].sort_by!(&:date).reverse!
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

  def set_ignored_entities
    ignored_tags = Tag.select(:id).ignored
    @expenses_to_ignore = Expense.with_these_tags(ignored_tags)
    @debits_to_ignore = Debit.with_these_tags(ignored_tags)
  end
end
