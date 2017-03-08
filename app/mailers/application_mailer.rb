class ApplicationMailer < ActionMailer::Base
  default from: ENV['APP_EMAIL_SENDER']
  layout 'mailer'
end
