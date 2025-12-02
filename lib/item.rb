module Lab1
  class Item
    attr_accessor :name, :price, :description, :category, :image_path

    def initialize(name, price, description: nil, category: nil, image_path: nil)
      @name = name
      @price = price
      @description = description
      @category = category
      @image_path = image_path
    end

    def to_s
      "#{name} (#{price})"
    end

    def to_h
      {
        name: name,
        price: price,
        description: description,
        category: category,
        image_path: image_path
      }
    end

    def inspect
      "#<Item #{to_h}>"
    end
  end
end
