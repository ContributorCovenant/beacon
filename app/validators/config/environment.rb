# Load the Rails application.
require File.expand_path('../application', __FILE__)
Setting.load(path: "#{Rails.root}/config/settings",
             files: ["default.yml", "environments/#{Rails.env}.yml"])

# Initialize the Rails application.
Gregory::Application.initialize!
