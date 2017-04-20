# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :set_tag, except: %i[index new]

  def index
    @tags = current_user.tags
  end

  def show
    @expenses_count = Tagging.where(
      taggable_type: 'Expense',
      tag_id: @tag.id
    ).count
    @debits_count = Tagging.where(
      taggable_type: 'Debit',
      tag_id: @tag.id
    ).count
  end

  def new
    @tag = Tag.new
  end

  def edit; end

  def update
    if @tag.update(tag_params)
      redirect_to @tag, notice: t(:'tags.update.flash.success')
    else
      render :edit
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_url, notice: t(:'tags.destroy.flash.success')
  end

  def chart
    ignore_tag_ids = Tag.select(:id).ignored
    tag_id = @tag.id

    settings = {
      lines: [
        { type: :curve, name: I18n.t(:'tags.chart.monthly'), covers: 6 },
        { type: :average, name: I18n.t(:'tags.chart.monthly_average'), covers: 6 },
        { type: :average, name: I18n.t(:'tags.chart.yearly_average'), covers: 12 },
      ],
      name: I18n.t(:'tags.chart.chart_title', tag: @tag.name),
      months: 6,
      expenses_lb: -> (u) { Expense.include_taggings
                                   .date_after(u)
                                   .where(taggings: { tag_id: tag_id })
                                   .where.not( id: Expense.with_these_tags(ignore_tag_ids) ) },
      debits_lb: -> (u) { Debit.end_date_after(u)
                               .or(Debit.where(end_date: nil))
                               .start_date_before(Date.today)
                               .where( id: Debit.with_these_tags(tag_id) ) }
    }

    @chart = ChartsService.new(settings).build_chart
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :ignored)
  end
end
