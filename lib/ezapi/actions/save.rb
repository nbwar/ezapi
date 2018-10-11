module EZApi
  module Actions
    module Save
      def save
        # response = self.class.client.send(request_type, save_path, as_json)
        response = false
        assign_attributes(response) if response
        self
      end

      private

      def request_type
        id ? :put : :post
      end

      def save_path
        [self.class.api_path, id].compact.join('/')
      end
    end
  end
end
