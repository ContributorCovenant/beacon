class AsyncMailer < ActionMailer::Base
  include Resque::Mailer
end
