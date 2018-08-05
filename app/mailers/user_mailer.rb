# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def email_modified_email(user, email_was, to)
    @user = user
    @email_was = email_was
    @app_name = I18n.t(:'layouts.application_name')
    mail(to: to, subject: I18n.t(:'user_mailer.email_modified_email.subject', app_name: @app_name))
  end
end
