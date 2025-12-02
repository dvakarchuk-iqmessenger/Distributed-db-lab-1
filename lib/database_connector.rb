require "fileutils"
require "sqlite3"
require "mongo"
require_relative "app_config_loader"
require_relative "logger_manager"


module Lab1
  class DatabaseConnector
    attr_reader :db_type, :db

    def initialize
      LoggerManager.setup

      loader = AppConfigLoader.new
      cfg    = loader.load_database_config["databaseconfig"]

      @db_type = cfg["databasetype"]
      @sqlite_cfg = cfg["sqlitedatabase"] || {}
      @mongo_cfg  = cfg["mongodb"] || {}
      @db = nil
    end

    def connect_to_database
      case db_type
      when "sqlite"
        connect_to_sqlite
      when "mongodb"
        connect_to_mongodb
      else
        raise ArgumentError, "Unsupported database type: #{db_type}"
      end
    rescue StandardError => e
      LoggerManager.error("Database connection error: #{e}")
      @db = nil
    end

    def close_connection
      if db_type == "sqlite" && db
        db.close
        LoggerManager.info("SQLite connection closed")
      elsif db_type == "mongodb" && db
        db.client.close
        LoggerManager.info("MongoDB connection closed")
      end
    rescue StandardError => e
      LoggerManager.error("Error while closing DB connection: #{e}")
    ensure
      @db = nil
    end

    private

    def connect_to_sqlite
      file = @sqlite_cfg["dbfile"] || "db/localdatabase.sqlite"
      FileUtils.mkdir_p(File.dirname(file))
      @db = SQLite3::Database.new(file)
      LoggerManager.info("Connected to SQLite database at #{file}")
      @db
    end

    def connect_to_mongodb
      uri    = @mongo_cfg["uri"]    || "mongodb://localhost:27017"
      dbname = @mongo_cfg["dbname"] || "mydatabase"

      client = Mongo::Client.new(uri, database: dbname)
      @db = client.database
      LoggerManager.info("Connected to MongoDB database #{dbname} at #{uri}")
      @db
    end
  end
end
