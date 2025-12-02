require "yaml"
require "erb"

class AppConfigLoader
  def initialize(config_dir: File.join(__dir__, "..", "config"))
    @config_dir = File.expand_path(config_dir)
  end

  def load_config(name)
    path = File.join(@config_dir, "#{name}.yaml")
    raw = File.read(path)
    erb_result = ERB.new(raw).result
    YAML.safe_load(erb_result, aliases: true)
  end

  def load_default_config
    load_config("defaultconfig")
  end

  def load_webparser_config
    load_config("webparser")
  end

  def load_logging_config
    load_config("logging")
  end

  def load_database_config
    load_config("databaseconfig")
  end
end
