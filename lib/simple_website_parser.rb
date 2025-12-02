require "httparty"
require "nokogiri"
require "fileutils"
require_relative "app_config_loader"
require_relative "item"
require_relative "logger_manager"

module Lab1
  class SimpleWebsiteParser
    attr_reader :config, :items

    def initialize
      loader = AppConfigLoader.new
      @config = loader.load_config("simple_parser")["simple_parser"]
      @items  = []
      LoggerManager.setup
    end

    def start_parse
      url = config["start_page"]
      LoggerManager.info("SimpleWebsiteParser: start parsing #{url}")

      page = fetch_page(url)
      return unless page

      product_links = extract_products_links(page)
      LoggerManager.info("Found #{product_links.size} product links")

      threads = product_links.map do |link|
        Thread.new do
          parse_product_page(absolute_url(url, link))
        end
      end

      threads.each(&:join)

      LoggerManager.info("SimpleWebsiteParser: parsed #{items.size} products")
      items
    end

    def extract_products_links(page)
      page.css(config["product_selector"]).map { |a| a["href"] }.compact
    end

    def parse_product_page(product_link)
      return unless check_url_response(product_link)

      LoggerManager.info("Parse product page #{product_link}")
      page = fetch_page(product_link)
      return unless page

      name        = extract_product_name(page)
      price       = extract_product_price(page)
      description = extract_product_description(page)
      category    = extract_product_category(page)
      image_url   = extract_product_image(page)
      image_path  = download_image(image_url, category, name) if image_url

      item = Item.new(
        name,
        price,
        description: description,
        category: category,
        image_path: image_path
      )

      @items << item
    rescue StandardError => e
      LoggerManager.error("Error parsing product #{product_link}: #{e}")
    end

    def extract_product_name(page)
      page.css("div.product_main h1").text.strip
    end

    def extract_product_price(page)
      text = page.css(config["price_selector"]).first&.text.to_s
      text.gsub(/[^\d\.]/, "").to_f
    end

    def extract_product_description(page)
      page.css(config["description_selector"]).text.strip
    end

    def extract_product_category(page)
      page.css(config["category_selector"]).text.strip
    end

    def extract_product_image(page)
      src = page.css(config["image_selector"]).first&.[]("src")
      return nil unless src

      src.start_with?("http") ? src : absolute_url(config["start_page"], src)
    end

    def check_url_response(url)
      resp = HTTParty.get(url)
      resp.code.between?(200, 299)
    rescue StandardError => e
      LoggerManager.error("URL not available #{url}: #{e}")
      false
    end

    private

    def fetch_page(url)
      resp = HTTParty.get(url)
      Nokogiri::HTML(resp.body)
    end

    def absolute_url(base, href)
      URI.join(base, href).to_s
    end

    def download_image(url, category, name)
      media_root = File.expand_path(config["media_dir"], File.join(__dir__, ".."))
      safe_category = (category || "uncategorized").gsub(/[^\w\-]/, "_")
      dir = File.join(media_root, safe_category)
      FileUtils.mkdir_p(dir)

      ext  = File.extname(URI.parse(url).path)
      safe_name = name.gsub(/[^\w\-]/, "_")[0, 50]
      path = File.join(dir, "#{safe_name}#{ext}")

      File.open(path, "wb") do |f|
        f.write(HTTParty.get(url).body)
      end

      path
    rescue StandardError => e
      LoggerManager.error("Error downloading image #{url}: #{e}")
      nil
    end
  end
end
