require "httparty"
require "nokogiri"

response = HTTParty.get("https://example.com")
doc = Nokogiri::HTML(response.body)

puts "Page title:"
puts doc.css("h1").text
