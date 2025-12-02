require "json"
require "csv"
require "yaml"
require_relative "item_container"
require_relative "logger_manager"

module Lab1
  class Cart
    include ItemContainer
    include Enumerable

    attr_reader :items

    def initialize(items = [])
      @items = items
      LoggerManager.setup
      self.class.increment_created
      LoggerManager.info("Cart created with #{items.size} items")
    end

    def each(&block)
      items.each(&block)
    end

    # Файли: output/data.txt, output/data.json, output/data.csv, output/yaml_items/
    def save_to_file(path = File.join(__dir__, "..", "output", "data.txt"))
      LoggerManager.info("Saving items to text file: #{path}")
      File.open(path, "w") do |f|
        items.each { |item| f.puts(item.to_s) }
      end
    end

    def save_to_json(path = File.join(__dir__, "..", "output", "data.json"))
      LoggerManager.info("Saving items to JSON: #{path}")
      data = items.map(&:to_h)
      File.write(path, JSON.pretty_generate(data))
    end

    def save_to_csv(path = File.join(__dir__, "..", "output", "data.csv"))
      LoggerManager.info("Saving items to CSV: #{path}")
      CSV.open(path, "w", col_sep: ",") do |csv|
        csv << %w[name price description category image_path]
        items.each do |item|
          csv << [item.name, item.price, item.description, item.category, item.image_path]
        end
      end
    end

    def save_to_yml(dir = File.join(__dir__, "..", "output", "yaml_items"))
      LoggerManager.info("Saving items to YAML dir: #{dir}")
      Dir.mkdir(dir) unless Dir.exist?(dir)
      items.each_with_index do |item, index|
        path = File.join(dir, "item_#{index + 1}.yml")
        File.write(path, item.to_h.to_yaml)
      end
    end

    # Приклади методів на Enumerable

    def total_price
      reduce(0.0) { |sum, item| sum + item.price.to_f }
    end

    def expensive_items(threshold)
      select { |item| item.price.to_f > threshold }
    end

    def find_by_name(name)
      find { |item| item.name == name }
    end
  end
end
