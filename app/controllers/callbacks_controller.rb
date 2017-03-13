class CallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(provider)
    class_eval %(
      def #{provider}
        @user = User.from_omniauth omniauth_auth
        sign_in_and_redirect @user
      end
    )
  end

  %i(twitter facebook).each do |provider|
    provides_callback_for provider
  end

  private

  def omniauth_auth
    request.env['omniauth.auth']
  end
end
