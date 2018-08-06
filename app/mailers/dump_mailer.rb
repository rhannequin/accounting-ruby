# frozen_string_literal: true

class DumpMailer < ApplicationMailer
  def dump_email(to, dump)
    attachments[File.basename(dump)] = File.read(dump)
    app_name = I18n.t(:"layouts.application_name")
    mail(to: to,
         subject: I18n.t(:"dump_mailer.dump_email.subject", app_name: app_name))
  end
end
