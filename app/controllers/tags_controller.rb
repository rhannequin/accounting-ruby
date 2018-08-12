# frozen_string_literal: true

class TagsController < ApplicationController
  load_and_authorize_resource

  before_action :set_account_id, :set_account
  before_action :set_tag, except: %i[index new]

  def index
    @tags = Tag.where(account: @account)
  end

  def show
    @expenses_count = Tagging.where(
      taggable_type: "Expense",
      tag_id: @tag.id
    ).count
  end

  def new
    @tag = Tag.new
  end

  def edit; end

  def update
    if @tag.update(tag_params)
      redirect_to account_tag_path(@account_id, @tag.id), notice: t(:"tags.update.flash.success")
    else
      render :edit
    end
  end

  def destroy
    @tag.destroy
    redirect_to account_tags_url(@account_id), notice: t(:"tags.destroy.flash.success")
  end

  def chart
    ignore_tag_ids = Tag.select(:id).ignored
    tag_id = @tag.id
    account = @tag.account

    settings = {
      lines: [
        { type: :curve, name: I18n.t(:"tags.chart.monthly"), covers: 6 },
        { type: :average, name: I18n.t(:"tags.chart.monthly_average"), covers: 6 },
        { type: :average, name: I18n.t(:"tags.chart.yearly_average"), covers: 12 },
        { type: :average, name: I18n.t(:"tags.chart.all_time_average"), covers: nil }
      ],
      name: I18n.t(:"tags.chart.chart_title", tag: @tag.name),
      months: 6,
      account: account,
      expenses_lb: -> (u) { account.expenses.include_taggings
                                   .date_after(u)
                                   .where(taggings: { tag_id: tag_id })
                                   .where.not(id: account.expenses.with_these_tags(ignore_tag_ids)) }
    }

    @chart = ChartsService.new(settings).build_chart
  end

  private

    def set_account_id
      @account_id = params.require(:account_id)
    end

    def set_account
      @account = Account.find(@account_id)
    end

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name, :ignored)
    end
end
