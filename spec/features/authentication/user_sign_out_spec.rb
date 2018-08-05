# frozen_string_literal: true

require "rails_helper"

feature "Sign out" do
  background do
    user = create(:user)
    login_with(user)
    visit root_path
    click_link I18n.t(:"devise.sessions.destroy.sign_out")
  end

  scenario "successfully sign out" do
    expect(page).to have_content I18n.t(:"devise.sessions.signed_out")
    expect(current_path).to eq(root_path)
  end
end
