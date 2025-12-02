require_relative "website_parser"

parser = Lab1::WebsiteParser.new
items  = parser.parse

puts "Parsed #{items.size} items"
items.each do |item|
  p item.to_h
end

