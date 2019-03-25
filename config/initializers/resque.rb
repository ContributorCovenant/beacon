rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'
config_file = rails_root + '/config/resque.yml'

resque_config = YAML.safe_load(ERB.new(IO.read(config_file)).result)
Resque.redis = resque_config[rails_env]
