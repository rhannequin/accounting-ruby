# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Setting.exists? ? Setting.first.email : "from@example.com"
  layout "mailer"
end
