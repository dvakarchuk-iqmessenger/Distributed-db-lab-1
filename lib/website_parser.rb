require "httparty"
require "nokogiri"
require_relative "app_config_loader"
require_relative "item"
require_relative "logger_manager"

module Lab1
  class WebsiteParser
    def initialize
      config_loader = AppConfigLoader.new
      @cfg = config_loader.load_webparser_config["webparser"]
      LoggerManager.setup
    end

    def parse
      url = @cfg["start_page"]
      LoggerManager.info("Fetching #{url}")

      response = HTTParty.get(url)
      doc = Nokogiri::HTML(response.body)

      products        = doc.css(@cfg["product_selector"])
      category_text   = doc.css(@cfg["category_selector"]).text.strip
      items           = []

      products.each do |product|
        title_node = product.css(@cfg["title_selector"]).first
        price_node = product.css(@cfg["price_selector"]).first
        image_node = product.css(@cfg["image_selector"]).first

        next unless title_node && price_node

        name  = title_node["title"] || title_node.text.strip
        price = price_node.text.gsub(/[^\d\.]/, "").to_f
        image = image_node ? image_node["src"] : nil

        item = Item.new(
          name,
          price,
          description: "Book from books.toscrape.com",
          category: category_text.empty? ? "All books" : category_text,
          image_path: image
        )

        LoggerManager.info("Parsed item: #{item.to_s}")
        items << item
      end

      items
    rescue StandardError => e
      LoggerManager.error("Error parsing #{@cfg['start_page']}: #{e}")
      []
    end
  end
end
