# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github){ |repo| "https://github.com/#{repo}.git" }

ruby "2.5.3"

gem "rails", "~> 5.2.2"

gem "aasm"
gem "autoprefixer-rails"
gem "bootsnap", ">= 1.1.0", require: false
gem "bootstrap", "~> 4.2.1"
gem "bootstrap-toggle-rails"
gem "bootswatch"
gem "coffee-rails", "~> 4.2"
gem "devise"
gem "dotenv-rails"
gem "google-cloud-storage", require: false
gem "jbuilder", "~> 2.5"
gem "jquery-rails"
gem "fittings"
gem "normailize"
gem "omniauth-github", github: "intridea/omniauth-github"
gem "omniauth-gitlab", github: "linchus/omniauth-gitlab"
gem "pg"
gem "popper_js", "~> 1.14.5"
gem "puma", "~> 3.11"
gem "recaptcha"
gem "sass-rails", "~> 5.0"
gem "sendgrid-ruby"
gem "sprockets-es6"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"
gem "valid_email2"

group :development, :test do
  gem "brakeman"
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "pry"
  gem "rails_layout", github: "RailsApps/rails_layout"
  gem "rubocop", "~> 0.62.0"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "chromedriver-helper"
  gem "factory_bot_rails"
  gem "launchy"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "simplecov", require: false
end

gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
