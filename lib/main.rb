require_relative "website_parser"
require_relative "cart"

parser = Lab1::WebsiteParser.new
items  = parser.parse

cart = Lab1::Cart.new
items.each { |item| cart.add_item(item) }

puts Lab1::Cart.class_info
puts "Items in cart: #{cart.items.size}"
puts "Total price: #{cart.total_price}"

cart.save_to_file
cart.save_to_json
cart.save_to_csv
cart.save_to_yml

puts "Cart saved to output/."
