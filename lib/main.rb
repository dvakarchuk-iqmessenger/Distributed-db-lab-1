require_relative "database_connector"

connector = Lab1::DatabaseConnector.new
connector.connect_to_database
puts "DB type: #{connector.db_type}, connected: #{!connector.db.nil?}"
connector.close_connection
