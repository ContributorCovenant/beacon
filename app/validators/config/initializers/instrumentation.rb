dd_app_name = StitchFix::Instrumentation::configuration.app_name

::Datadog.configure do |c|
  c.use :resque, workers: [ApplicationJob], service_name: "resque-#{dd_app_name}"
end
