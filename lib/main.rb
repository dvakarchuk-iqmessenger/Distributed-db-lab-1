require_relative "configurator"
require_relative "website_parser"
require_relative "cart"

configurator = Lab1::Configurator.new

items = []

if configurator.enabled?(:run_website_parser)
  parser = Lab1::WebsiteParser.new
  items  = parser.parse
  puts "Parsed #{items.size} items"
else
  puts "Website parser is disabled in configurator."
end

cart = Lab1::Cart.new

items.each { |item| cart.add_item(item) }

if configurator.enabled?(:run_save_to_csv)
  cart.save_to_csv
end

if configurator.enabled?(:run_save_to_json)
  cart.save_to_json
end

if configurator.enabled?(:run_save_to_yaml)
  cart.save_to_yml
end

# Заглушки під майбутні етапи з БД
if configurator.enabled?(:run_save_to_sqlite)
  puts "SQLite saving is enabled (not implemented yet)."
end

if configurator.enabled?(:run_save_to_mongodb)
  puts "MongoDB saving is enabled (not implemented yet)."
end
