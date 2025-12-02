require_relative "app_config_loader"

loader = AppConfigLoader.new

default_cfg  = loader.load_default_config
web_cfg      = loader.load_webparser_config
logging_cfg  = loader.load_logging_config
database_cfg = loader.load_database_config

puts "Default config:"
p default_cfg

puts "\nWeb parser config:"
p web_cfg

puts "\nLogging config:"
p logging_cfg

puts "\nDatabase config:"
p database_cfg
