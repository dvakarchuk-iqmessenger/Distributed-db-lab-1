require_relative "app_config_loader"

module Lab1
  class Configurator
    attr_reader :config

    DEFAULT_CONFIG = {
      "run_website_parser" => 0,
      "run_save_to_csv"    => 0,
      "run_save_to_json"   => 0,
      "run_save_to_yaml"   => 0,
      "run_save_to_sqlite" => 0,
      "run_save_to_mongodb"=> 0
    }.freeze

    def initialize
      loader = AppConfigLoader.new
      raw = loader.load_config("configurator")
      @config = DEFAULT_CONFIG.merge(raw["config"] || {})
    end

    # дозволяє змінити окремі прапорці в рантаймі
    def configure(overrides = {})
      @config.merge!(overrides.transform_keys(&:to_s))
    end

    # список доступних «кроків»
    def available_methods
      @config.keys
    end

    def enabled?(key)
      @config[key.to_s].to_i == 1
    end
  end
end
