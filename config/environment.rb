# Load the Rails application.
require_relative 'application'
# Initialize the Rails application.
Setting.load(path: "#{Rails.root}/config/settings", files: ["default.yml", "environments/#{Rails.env}.yml"])

Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  user_name: ENV['SENDGRID_USERNAME'],
  password: ENV['SENDGRID_PASSWORD'],
  domain: 'coc-beacon.org',
  host: 'coc-beacon.herokuapp.com',
  address: 'smtp.sendgrid.net',
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true
}
