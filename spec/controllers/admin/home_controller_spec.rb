# frozen_string_literal: true

require "rails_helper"

describe Admin::HomeController, type: :controller do
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
