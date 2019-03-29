Bugsnag.configure do |config|
  config.notify_release_stages = ["production", "staging"]
  config.api_key = ENV['BUGSNAG_API_KEY']
end
