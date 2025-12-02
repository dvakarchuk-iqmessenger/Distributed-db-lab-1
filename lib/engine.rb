require "yaml"
require_relative "app_config_loader"
require_relative "logger_manager"
require_relative "simple_website_parser"
require_relative "cart"
require_relative "database_connector"

module Lab1
  class Engine
    attr_reader :config, :items, :cart, :db_connector

    def initialize
      @items        = []
      @cart         = Cart.new
      @db_connector = DatabaseConnector.new
    end

    def load_config
      loader = AppConfigLoader.new
      @config = loader.load_config("engine")["engine"] || {}
      LoggerManager.info("Engine config loaded: #{@config}")
    end

    def run(config_params = nil)
      initialize_logging
      load_config
      @config.merge!(config_params.transform_keys(&:to_s)) if config_params

      db_connector.connect_to_database
      run_methods(@config)
    ensure
      db_connector.close_connection
    end

    def run_methods(config_params)
      config_params.each do |key, value|
        next unless value.to_i == 1

        method_name = key.to_s
        if respond_to?(method_name, true)
          LoggerManager.info("Engine: running #{method_name}")
          send(method_name)
        else
          LoggerManager.error("Engine: method #{method_name} not found")
        end
      end
    end

    private

    def initialize_logging
      LoggerManager.setup
      LoggerManager.info("Engine logging initialized")
    end

    # --- дії з конфіга ---

    def run_website_parser
      parser = SimpleWebsiteParser.new
      @items = parser.start_parse
      @items.each { |item| cart.add_item(item) }
    end

    def run_save_to_csv
      cart.save_to_csv
    end

    def run_save_to_json
      cart.save_to_json
    end

    def run_save_to_yaml
      cart.save_to_yml
    end

    def run_save_to_sqlite
      return unless db_connector.db_type == "sqlite" && db_connector.db

      db = db_connector.db
      db.execute <<~SQL
        CREATE TABLE IF NOT EXISTS books (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price REAL,
          description TEXT,
          category TEXT,
          image_path TEXT
        );
      SQL

      cart.each do |item|
        db.execute(
          "INSERT INTO books (name, price, description, category, image_path) VALUES (?, ?, ?, ?, ?)",
          [item.name, item.price, item.description, item.category, item.image_path]
        )
      end

      LoggerManager.info("Saved #{cart.items.size} items to SQLite")
    end

    def run_save_to_mongodb
      return unless db_connector.db_type == "mongodb" && db_connector.db

      collection = db_connector.db["books"]
      docs = cart.map(&:to_h)
      collection.insert_many(docs)
      LoggerManager.info("Saved #{docs.size} items to MongoDB")
    end
  end
end
