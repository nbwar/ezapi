module EZApi
  module DSL
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def path(url)
        define_singleton_method(:api_path) { url }
      end

      def actions(actions)
        actions.each { |action| include EZApi::Actions.const_get(action.to_s.camelize) }
        if (actions & [:create, :update]).any? && !actions.include?(:save)
          include EZApi::Actions::Save
        end
      end

      def client
        client_name = self.name.deconstantize
        @client ||= !client_name.empty? ? client_name.constantize : EZApi::Client
      end

      def api_path
        path = self.name.demodulize.underscore.pluralize
        "#{CGI.escape(path)}"
      end
    end

  end
end
