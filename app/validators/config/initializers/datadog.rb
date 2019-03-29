require "net/http"
require "ddtrace"

dd_app_name        = Rails.application.class.parent.name
is_rails_console   = Rails.const_defined?("Console")
dd_tracing_enabled =  ENV.has_key?("DD_AGENT_PORT_8126_TCP_ADDR") && !is_rails_console

Datadog::Monkey.patch_all if dd_tracing_enabled

Rails.configuration.datadog_trace = {
    enabled: dd_tracing_enabled,
    auto_instrument: true,
    auto_instrument_redis: true,
    default_controller_service: "rails-controller-#{dd_app_name}",
    default_cache_service: "rails-cache-#{dd_app_name}",
    default_database_service: "postgresql-#{dd_app_name}",
    default_service: dd_app_name,
    trace_agent_hostname: ENV["DD_AGENT_PORT_8126_TCP_ADDR"],
    trace_agent_port: ENV["DD_AGENT_PORT_8126_TCP_PORT"]
}