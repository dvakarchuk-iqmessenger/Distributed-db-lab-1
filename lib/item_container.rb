module Lab1
  module ItemContainer
    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end

    module ClassMethods
      def class_info
        "#{name} v1.0"
      end

      def created_count
        @created_count ||= 0
      end

      def increment_created
        @created_count = created_count + 1
      end
    end

    module InstanceMethods
      def add_item(item)
        items << item
        LoggerManager.info("Added item: #{item}")
      end

      def remove_item(item)
        items.delete(item)
        LoggerManager.info("Removed item: #{item}")
      end

      def delete_items
        items.clear
        LoggerManager.info("Deleted all items")
      end

      def method_missing(name, *args, &block)
        if name == :show_all_items
          items.each { |i| puts i.to_s }
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        name == :show_all_items || super
      end
    end
  end
end
