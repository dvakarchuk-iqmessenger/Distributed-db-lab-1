require_relative "app_config_loader"
require_relative "configurator"
require_relative "engine"

begin
  loader        = AppConfigLoader.new
  engine_config = loader.load_config("engine")["engine"] || {}

  configurator = Lab1::Configurator.new
  configurator.configure(engine_config)

  engine = Lab1::Engine.new
  engine.run(configurator.config)

  puts "Application finished successfully."
rescue StandardError => e
  puts "Error while starting application: #{e.message}"
end
