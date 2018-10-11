module EZApi
  module Actions
    module Show
      module ClassMethods
        def show(id)
          # response = client.get("#{api_path}/#{id}")
          response = {
            'id' => '2',
            'warehouse' => 'Albertsons',
            'user' => {
              'first_name' => 'Nick',
              'last_name' => 'wargnier'
            },
            'order_deliveries' => [
              {'foo' => 'bar'}
            ]
          }
          self.new(response)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
