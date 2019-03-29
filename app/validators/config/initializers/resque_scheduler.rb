Resque::Scheduler.configure do |c|
  c.verbose = true
  c.logfile = nil # meaning all messages go to $stdout
  c.logformat = 'text'
end

require 'ced_files_pipeline/jobs/kickoff_pipeline_job'
