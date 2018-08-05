# frozen_string_literal: true

require "rails_helper"

describe "admin/users/index.html.haml" do
  before(:each) do
    allow(view).to receive_messages(current_user: nil)
  end

  describe "usual scenario" do
    let(:users) { create_list :user, 2 }

    before(:each) do
      assign :users, users
    end

    it "displays users attributes" do
      render
      users.each do |user|
        expect(rendered).to include(user.id.to_s)
        expect(rendered).to include(user.name)
        expect(rendered).to include(user.email)
        expect(rendered).to include(l(user.created_at, format: :short))
        expect(rendered).to include(admin_user_path(user))
      end
    end
  end

  describe "about roles" do
    let(:users) { create_list :user, 2 }

    before(:each) do
      users.sample.grant :admin
      assign :users, users
    end

    it "displays users attributes" do
      render
      users.each do |user|
        expect(rendered).to include(roles_list(user.roles))
      end
    end
  end

  describe "about friendly_id" do
    let(:name) { "jane" }
    let(:user) { create :user, name: name }

    before(:each) do
      user.grant :admin
      assign :users, [user]
    end

    it "has name in url" do
      render
      expect(admin_user_path(user)).to include(name)
    end
  end

  describe "with OmniAuth accounts" do
    it "displays username" do
      users = [create(:user, :with_twitter_account), create(:user, :with_twitter_account)]
      assign :users, users
      render
      users.each do |user|
        expect(rendered).to include(user.name)
        expect(rendered).to include(user.provider)
      end
    end
  end
end
