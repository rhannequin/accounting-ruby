# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    load_and_authorize_resource

    def index
      @users = User.all
    end

    def show; end

    def destroy
      @user.errors[:base] << :is_current_user unless can?(:destroy, @user)
      @user.destroy
      flash[:notice] = t(:'flash.admin.users.destroy.success')
      redirect_to action: :index
    end
  end
end
