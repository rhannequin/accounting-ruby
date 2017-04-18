class ExpensesController < ApplicationController
  include ApplicationHelper
  include ExpensesHelper
  before_action :set_account
  before_action :set_expense, only: [:edit, :update, :destroy]

  def show
    @expense = Expense.include_tags.find(params[:id])
  end

  def new
    @expense = Expense.new
  end

  def edit; end

  def create
    params = expense_params
    tags = params['tag_ids']
    params.delete('tag_ids')
    @expense = Expense.new(params)

    if @expense.save && (@expense.tag_ids = tags)
      redirect_to @expense, notice: t(:'expenses.create.flash.success')
    else
      render :new
    end
  end

  def update
    if @expense.update(expense_params)
      redirect_to account_expense_path(@account.id, @expense.id), notice: t(:'expenses.update.flash.success')
    else
      render :edit
    end
  end

  def destroy
    @expense.destroy
    redirect_to @account, notice: t(:'expenses.destroy.flash.success')
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
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
