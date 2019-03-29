web: bundle exec puma -C config/puma.rb
resque: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7 QUEUE=* bundle exec rake resque:work
