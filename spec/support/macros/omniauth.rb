# frozen_string_literal: true

module Macros
  module Omniauth
    def self.provides_mock_for(provider)
      class_eval %(
        def mock_auth_#{provider}
          OmniAuth.config.add_mock :#{provider}, uid: "12345", info: {
            name: "#{provider.capitalize} User",
            provider: :#{provider},
            email: "#{provider}-user@example.com"
          }
        end
      )
    end

    %i[twitter facebook].each do |provider|
      provides_mock_for provider
    end

    def log_in_with_omniauth(provider)
      send :"mock_auth_#{provider}"
      visit send(:"user_#{provider}_omniauth_authorize_path")
    end
  end
end
