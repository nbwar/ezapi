module EZApi
  class ObjectBase
    include EZApi::DSL

    attr_reader :params

    def initialize(params={})
      assign_attributes(params)
      @params = params.with_indifferent_access
    end

    def id
      attributes['id']
    end

    def id=(value)
      attributes['id'] = value
    end

    def as_json(*options)
      attributes.as_json(*options)
    end

    private
      def assign_attributes(params)
        return unless params.present?

        params.each do |key, value|
          key = key.to_s.underscore
          define_attribute_accessors(key) unless respond_to?(key)
          # TODO: Support creating real api objects based on associations
          case value
          when Array
            value = value.map do |obj|
              obj.is_a?(Hash) ? ObjectBase.new(obj) : obj
            end
          when Hash
            value = ObjectBase.new(value)
          end

          public_send(:"#{key}=", value)
        end
      end

      def define_attribute_accessors(attr)
        attr = attr.to_s
        define_singleton_method(:"#{attr}=") { |value| attributes[attr] = value }
        define_singleton_method(attr) { attributes[attr] }
      end

      def attributes
        @attributes ||= {}
      end
  end
end
