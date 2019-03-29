ClientService.configure do |config|
  config.endpoint = ENV['CLIENT_SERVICE_ENDPOINT'] || raise('Missing environment variable: CLIENT_SERVICE_ENDPOINT')
  config.api_key = ENV['CLIENT_SERVICE_API_KEY'] || raise('Missing environment variable: CLIENT_SERVICE_API_KEY')
  config.version = 1
end
