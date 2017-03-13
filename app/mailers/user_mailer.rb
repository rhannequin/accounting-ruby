class UserMailer < ApplicationMailer
  def email_changed_email(user, email_was, to)
    @user = user
    @email_was = email_was
    @app_name = I18n.t(:'layouts.application_name')
    mail(to: to, subject: I18n.t(:'user_mailer.email_changed_email.subject', app_name: @app_name))
  end
end
