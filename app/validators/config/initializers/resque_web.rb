require 'resque-cleaner'

module Resque::Plugins
  ResqueCleaner::Limiter.default_maximum = 10_000
end