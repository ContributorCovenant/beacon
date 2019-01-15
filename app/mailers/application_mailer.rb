# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'beacon@idolhands.com'
  layout 'mailer'
end
