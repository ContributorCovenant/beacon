require 'resque/scheduler'
require 'resque/scheduler/server'
require 'resque-retry'
require 'resque-retry/server'
# Point it to redis to go on heroku environments
if ENV["REDIS_URL"].present?
  uri = URI.parse(ENV["REDIS_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

if Rails.env.test?
  Resque.inline = true
end

Resque.before_first_fork do
  ::ActiveSupport::Notifications.unsubscribe('sql.active_record')
end

Resque.before_fork do
  APP_DATABASES.each(&:disconnect!)
end

Resque.after_fork do
  APP_DATABASES.each(&:connect!)
end

require 'resque/failure/redis'
Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression
