module EZApi
  module Actions
    module Show
      module ClassMethods
        def show(id)
          response = client.get("#{api_path}/#{id}")
          self.new(response)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
