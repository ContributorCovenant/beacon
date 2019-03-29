require 'stitch_fix/logger'
require "stitch_fix/core_models/concerns"

unless ENV["BLOCK_CODE_THAT_REQUIRES_STRUCTURE"] == 'true'
  require 'stitch_fix/core_models'
  Dir.glob("#{Rails.root}/app/model_ext/*.rb").sort.each { |file| require_dependency file }
end

module StitchFix
  class SharedModel
    include StitchFix::CoreModels::Concerns::AccessLogger unless %w[1 true].include?(ENV['CORE_MODELS_LOGGING_OFF'])
  end
end
