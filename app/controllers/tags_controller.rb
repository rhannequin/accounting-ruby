class TagsController < ApplicationController
  before_action :set_tag

  def show
    @expenses_count = Tagging.where(taggable_type: 'Expense', tag_id: @tag.id).count
    @debits_count = Tagging.where(taggable_type: 'Debit', tag_id: @tag.id).count
  end

  def edit
  end

  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to @tag, notice: t(:'tags.update.flash.success') }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
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
      expenses_lb: -> (u) { Expense.includes(:taggings)
                                   .where(['date > ?', u])
                                   .where(taggings: { tag_id: tag_id })
                                   .where.not(
                                      id: Expense.joins(:taggings)
                                                 .where(taggings: { tag_id: ignore_tag_ids })
                                    ) },
      debits_lb: -> (u) { Debit.where(['end_date > ?', u])
                               .or(Debit.where(end_date: nil))
                               .where(['start_date < ?', Date.today])
                               .where(
                                  id: Debit.joins(:taggings)
                                           .where(taggings: { tag_id: tag_id })
                                ) }
    }

    @chart = ChartsService.new(settings).build_chart
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:name, :ignored)
    end
end
