class ApplicationMailer < ActionMailer::Base
  default from: Setting.emails(:robot)
  layout 'mailer'
end
