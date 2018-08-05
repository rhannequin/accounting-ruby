# frozen_string_literal: true

require "rails_helper"

describe "layouts/application.html.haml" do
  describe "general information" do
    it "shows current user's name" do
      user = create :user
      sign_in user
      render
      expect(rendered).to include(user.name)
    end
  end
end
