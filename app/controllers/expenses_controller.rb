# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :set_account_id, :set_account
  before_action :set_tags, only: %i[new edit]
  before_action :set_expense, only: %i[edit update destroy]

  load_resource :account
  load_and_authorize_resource :expense, through: :account

  def show
    @expense = Expense.include_tags
                      .find(params[:id])
  end

  def new; end

  def edit; end

  def create
    @expense = Expense.new(expense_params)
    @expense.account_id = @account_id
    if @expense.save
      flash[:notice] = t(:'expenses.create.flash.success')
      redirect_to account_expense_path(@account_id, @expense.id)
    else
      render :new
    end
  end

  def update
    if @expense.update(expense_params)
      flash[:notice] = t(:'expenses.update.flash.success')
      redirect_to account_expense_path(@account_id, @expense.id)
    else
      render :edit
    end
  end

  def destroy
    @expense.destroy
    flash[:notice] = t(:'expenses.destroy.flash.success')
    redirect_to account_path(@account_id)
  end

  private

    def set_account_id
      @account_id = params.require(:account_id)
    end

    def set_account
      @account = Account.find(@account_id)
    end

    def set_tags
      @tags = Tag.where(account_id: @account_id)
    end

    def set_expense
      @expense = Expense.find(params[:id])
    end

    def expense_params
      params.require(:expense).permit(:date, :reason, :price, :way, tag_ids: [])
    end
end
