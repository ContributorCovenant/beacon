# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
require 'dotenv'
Dotenv.overload '.env.test' if (ENV["RAILS_ENV"] || ENV["RACK_ENV"]) == 'test' && !ENV['CIRCLECI']
