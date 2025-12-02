require_relative "simple_website_parser"

parser = Lab1::SimpleWebsiteParser.new
items  = parser.start_parse

puts "Simple parser collected #{items.size} items"
items.each { |i| p i.to_h }
