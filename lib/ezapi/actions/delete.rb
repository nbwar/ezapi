module EZApi
  module Actions
    module Delete
      module ClassMethods
        def delete(id)
          response = client.delete("#{api_path}/#{id}")
          true
        end
      end

      def delete
        if id
          self.class.client.delete("#{self.class.api_path}/#{id}")
          true
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
