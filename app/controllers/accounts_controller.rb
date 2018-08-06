# frozen_string_literal: true

class AccountsController < ApplicationController
  include ApplicationHelper
  include ExpensesHelper

  load_and_authorize_resource

  before_action :authenticate_user!
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
    start_date = get_start_day(end_date, MONTHS_PER_PAGE)
    range = start_date..end_date
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
      redirect_to accounts_path, notice: t(:"accounts.create.flash.success")
    else
      render :new
    end
  end

  def update
    if @account.update(account_params)
      redirect_to accounts_path, notice: t(:"accounts.update.flash.success")
    else
      render :edit
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_url, notice: t(:"accounts.destroy.flash.success")
  end

  private

    def account_params
      params.require(:account).permit(:name)
    end

    def set_current_page
      page = params[:page]
      @current_page = page && page.to_i.positive? ? page.to_i : 1
    end

    def set_first_date
      @first_date = Expense.select(:date)
                           .where(account_id: @account.id)
                           .order(:date)
                           .first
                           .date
    end

    def set_ignored_entities
      ignored_tags = Tag.where(account_id: @account.id).select(:id).ignored
      @expenses_to_ignore = Expense.with_these_tags(ignored_tags).where(account_id: @account.id)
      @debits_to_ignore = Debit.with_these_tags(ignored_tags).where(account_id: @account.id)
    end

    def set_end_date
      @end_date = Expense.select(:date)
                         .where(account_id: @account.id)
                         .order("date DESC")
                         .first
                         .date
    end
end
