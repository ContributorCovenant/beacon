# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'donotreply@coc-beacon.org'
  layout 'mailer'
end
