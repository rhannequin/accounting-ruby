# frozen_string_literal: true

require "rails_helper"

feature "Sign in" do
  let(:user) { create(:user) }
  background do
    visit new_user_session_path
  end

  scenario "a user can see the sign in form" do
    expect(page).to have_content I18n.t(:"devise.sessions.new.sign_in")

    within "form#new_user" do
      expect(page).to have_field User.human_attribute_name(:email)
      expect(page).to have_field User.human_attribute_name(:password)
      expect(page).to have_unchecked_field User.human_attribute_name(:remember_me)
      expect(page).to have_button I18n.t(:"devise.sessions.new.sign_in")
    end
  end

  describe "when a user provides valid credentials" do
    background do
      within "form#new_user" do
        fill_in User.human_attribute_name(:email), with: user.email
        find("#user_password").set "password"
        click_button I18n.t(:"devise.sessions.new.sign_in")
      end
    end

    scenario "he should be signed in" do
      expect(current_path).to eq(root_path)
      expect(page).to have_content I18n.t(:"devise.sessions.signed_in")
      expect(page).to have_content user.name
      expect(page).to have_link I18n.t(:"devise.sessions.destroy.sign_out")
    end
  end

  %w[twitter facebook].each do |provider|
    describe "when signing up with #{provider.capitalize}" do
      background do
        log_in_with_omniauth(provider)
      end

      scenario "user is connected with his #{provider.capitalize} account" do
        expect(page).to have_content I18n.t(:"devise.sessions.destroy.sign_out")
        expect(page).to have_content "#{provider.capitalize} User" # See Macros::Omniauth
      end
    end
  end
end
