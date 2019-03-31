class ApplicationMailer < AsyncMailer
  default from: Setting.emails(:robot)
  layout 'mailer'
end
