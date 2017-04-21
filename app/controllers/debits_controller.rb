# frozen_string_literal: true

class DebitsController < ApplicationController
  before_action :set_account_id
  before_action :set_account, :set_tags, only: %i[new edit]
  before_action :set_debit, only: %i[edit update destroy]

  def index
    @debits = Debit.include_tags
                   .where(account_id: @account_id)
                   .order(start_date: :desc)
  end

  def show
    @debit = Debit.include_tags
                  .find(params.require(:id))
  end

  def new
    @debit = Debit.new
  end

  def edit; end

  def create
    @debit = Debit.new(debit_params)
    @debit.account_id = @account_id
    if @debit.save
      flash[:notice] = t(:'debits.create.flash.success')
      redirect_to account_debit_path(@account_id, @debit.id)
    else
      render :new
    end
  end

  def update
    if @debit.update(debit_params)
      flash[:notice] = t(:'debits.update.flash.success')
      redirect_to account_debit_path(@account_id, @debit.id)
    else
      render :edit
    end
  end

  def destroy
    @debit.destroy
    flash[:notice] = t(:'debits.destroy.flash.success')
    redirect_to account_debits_path(@account_id)
  end

  private

  def set_account_id
    @account_id = params.require(:account_id)
  end

  def set_account
    @account = Account.new(id: @account_id)
  end

  def set_tags
    @tags = Tag.where(account_id: @account_id)
  end

  def set_debit
    @debit = Debit.find(params[:id])
  end

  def debit_params
    params.require(:debit).permit(
      :reason,
      :price,
      :day,
      :way,
      :start_date,
      :end_date,
      tag_ids: []
    )
  end
end
