class TagsController < ApplicationController
  before_action :set_tag

  def edit
  end

  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to edit_tag_path(@tag), notice: t(:'tags.update.flash.success') }
        format.json { render :show, status: :ok, location: edit_tag_path(@tag) }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:name)
    end
end
