module EZApi
  module Actions
    module Index
      module ClassMethods
        def index(query_params, params = {})
          response = client.get(list_path(query_params), params)
          response.compact.map { |item| self.new(item) }
        end

        private
          def list_path(query_params)
            [api_path, build_query_params(query_params)].compact.join('?')
          end

          def build_query_params(query_params)
            query_params && query_params
              .collect { |key, value| "#{key}=#{URI.encode_www_form_component(value)}" }
              .join('&')
          end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
