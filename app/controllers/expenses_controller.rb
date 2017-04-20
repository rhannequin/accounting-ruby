# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :set_account_id
  before_action :set_account, only: %i[new edit]
  before_action :set_expense, only: %i[edit update destroy]

  def show
    @expense = Expense.include_tags.find(params[:id])
  end

  def new
    @expense = Expense.new
  end

  def edit; end

  def create
    @expense = Expense.new(expense_params)
    @expense.account_id = @account_id
    if @expense.save
      redirect_to account_expense_path(@account_id, @expense.id), notice: t(:'expenses.create.flash.success')
    else
      render :new
    end
  end

  def update
    if @expense.update(expense_params)
      redirect_to account_expense_path(@account_id, @expense.id), notice: t(:'expenses.update.flash.success')
    else
      render :edit
    end
  end

  def destroy
    @expense.destroy
    redirect_to account_path(@account_id), notice: t(:'expenses.destroy.flash.success')
  end

  private

  def set_account_id
    @account_id = params.require(:account_id)
  end

  def set_account
    @account = Account.new(id: @account_id)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_expense
    @expense = Expense.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_params
    params.require(:expense).permit(:date, :reason, :price, :way, tag_ids: [])
  end
end
