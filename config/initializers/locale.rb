# frozen_string_literal: true

# Internationalisation configuration

I18n.load_path += Dir[Rails.root.join("config", "locales", "*", "**", "*.{rb,yml}").to_s]
I18n.load_path += Dir[Rails.root.join("config", "locales", "*.{rb,yml}").to_s]
I18n.available_locales = %i( en fr )
I18n.default_locale = :fr
