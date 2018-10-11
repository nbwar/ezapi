module EZApi
  module Actions
    module Create
      module ClassMethods
        def create(params = {})
          obj = new(params)
          obj.save
          obj
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
