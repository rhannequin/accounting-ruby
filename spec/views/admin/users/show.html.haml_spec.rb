# frozen_string_literal: true

require "rails_helper"

describe "admin/users/show.html.haml" do
  describe "usual scenario" do
    let(:user) { create :user, :already_signed_in }

    before(:each) do
      assign :user, user
    end

    it "displays users attributes" do
      render
      expect(rendered).to include(user.id.to_s)
      expect(rendered).to include(user.name)
      expect(rendered).to include(user.email)
      expect(rendered).to include(l(user.created_at, format: :short))
      expect(rendered).to include(l(user.updated_at, format: :short))
      expect(rendered).to include(l(user.last_sign_in_at, format: :short))
      expect(rendered).to include(user.last_sign_in_ip)
      expect(rendered).to include(user.sign_in_count.to_s)
    end
  end

  describe "about roles" do
    let(:user) { create :user, :already_signed_in }

    before(:each) do
      user.grant :admin
      assign :user, user
    end

    it "displays users attributes" do
      render
      expect(rendered).to include(roles_list(user.roles))
    end
  end

  describe "with OmniAuth accounts" do
    it "displays username" do
      user = create(:user, :already_signed_in, :with_twitter_account)
      assign :user, user
      render
      expect(rendered).to include(user.provider)
    end
  end
end
