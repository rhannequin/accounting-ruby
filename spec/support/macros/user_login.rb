# frozen_string_literal: true

module Macros
  module UserLogin
    def login_with(user, options = {})
      options.reverse_merge!(password: "password")

      visit new_user_session_path

      within "form" do
        find("#user_email").set user.email
        find("#user_password").set options[:password]
        click_button I18n.t(:"devise.sessions.new.sign_in")
      end
    end

    def logout
      visit root_url
      click_link I18n.t(:"devise.sessions.destroy.sign_out")
    end
  end
end
