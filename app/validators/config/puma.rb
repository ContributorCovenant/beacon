workers Integer(ENV['WEB_CONCURRENCY'] || 2)

threads_count = Integer(ENV['MAX_THREADS'] || 1)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  APP_DATABASES.each(&:connect!)
end