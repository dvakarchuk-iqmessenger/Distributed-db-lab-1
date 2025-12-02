require "logger"
require_relative "app_config_loader"

module Lab1
  class LoggerManager
    class << self
      attr_reader :logger

      def setup
        loader = AppConfigLoader.new
        cfg = loader.load_logging_config["logging"]

        dir   = File.expand_path(cfg["directory"], File.join(__dir__, ".."))
        level = cfg["level"] || "INFO"
        file  = cfg.dig("files", "applicationlog") || "application.log"

        Dir.mkdir(dir) unless Dir.exist?(dir)

        log_path = File.join(dir, file)
        @logger = Logger.new(log_path)
        @logger.level = level_const(level)
      end

      def level_const(level)
        case level.to_s.upcase
        when "DEBUG" then Logger::DEBUG
        when "INFO"  then Logger::INFO
        when "WARN"  then Logger::WARN
        when "ERROR" then Logger::ERROR
        else Logger::INFO
        end
      end

      def info(message)
        ensure_logger
        @logger.info(message)
      end

      def error(message)
        ensure_logger
        @logger.error(message)
      end

      def log_processed_file(path)
        info("Processed file: #{path}")
      end

      private

      def ensure_logger
        setup unless @logger
      end
    end
  end
end
