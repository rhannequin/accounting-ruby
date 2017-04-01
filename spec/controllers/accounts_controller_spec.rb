require 'rails_helper'

describe AccountsController, type: :controller do
  describe 'GET #show' do
    let(:user) { create :user }

    before(:each) { sign_in user }

    before(:each) do
      @account = create(:account)
      @account.users << user
      @account.expenses << create(:expense)
    end

    it 'responds successfully with an HTTP 200 status code' do
      sign_in create(:user)
      get :show, params: { id: @account.id }
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end
end
