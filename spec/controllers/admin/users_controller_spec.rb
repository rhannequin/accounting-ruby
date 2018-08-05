# frozen_string_literal: true

require "rails_helper"

describe Admin::UsersController, type: :controller do
  describe "GET #index" do
    let(:user) { create :admin }

    before(:each) { sign_in user }

    it "can't access if not authorized" do
      sign_in create(:user)
      get :index
      expect(response).not_to be_successful
      expect(response).not_to have_http_status(200)
    end

    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "loads all of the users into @users" do
      user1 = create(:user)
      user2 = create(:user)
      get :index
      expect(assigns(:users)).to match_array([user, user1, user2])
    end
  end

  describe "GET #show" do
    let(:user) { create :admin }
    let(:user_showed) { create :user }

    before(:each) { sign_in user }

    it "can't access if not authorized" do
      sign_in create(:user)
      get :show, params: { id: user_showed.id }
      expect(response).not_to be_successful
      expect(response).not_to have_http_status(200)
    end

    it "responds successfully with an HTTP 200 status code" do
      get :show, params: { id: user_showed.id }
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end

    it "renders the show template" do
      get :show, params: { id: user_showed.id }
      expect(response).to render_template("show")
    end

    it "loads the user into @user" do
      get :show, params: { id: user_showed.id }
      expect(assigns(:user)).to eq(user_showed)
    end
  end

  describe "DELETE #destroy" do
    let(:connected_user) { create :admin }
    let(:user_to_destroy) { create :user }

    before(:each) { sign_in connected_user }

    it "destroys a user" do
      expect(User.find(user_to_destroy.id).deleted?).to be_falsy
      delete :destroy, params: { id: user_to_destroy.id }
      expect(User.unscoped.find(user_to_destroy.id).deleted?).to be_truthy
    end

    it "displays success flash message" do
      delete :destroy, params: { id: user_to_destroy.id }
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to eq(I18n.t(:"flash.admin.users.destroy.success"))
      expect(flash[:error]).not_to be_present
    end

    describe "trying to delete the current connected user" do
      it "does not work" do
        delete :destroy, params: { id: connected_user.id }
        expect(User.where(id: connected_user.id).count).to eq(1)
      end

      it "displays error flash message" do
        delete :destroy, params: { id: connected_user.id }
        expect(flash[:notice]).not_to be_present
        expect(flash[:error]).to be_present
        expect(flash[:error]).to eq(I18n.t(:"unauthorized.destroy.user"))
      end
    end

    it "redirects to #index" do
      delete :destroy, params: { id: user_to_destroy.id }
      expect(response).to redirect_to(admin_users_path)
    end
  end

  describe "authorization" do
    let(:user) { create :user }
    let(:previous_page) { edit_user_registration_path }

    before(:each) do
      sign_in user
      request.env["HTTP_REFERER"] = previous_page
    end

    it "redirects to previous page if not authorized" do
      get :index
      expect(response).to redirect_to(previous_page)
    end
  end
end
