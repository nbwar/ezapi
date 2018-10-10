require 'rest-client'
require 'json'
require 'base64'
require 'uri'

module EZApi
  module ApiClient
    attr_accessor :api_key
    attr_reader :base_url, :encoded_api_key, :app_name

    def request(api_url, method, params={})
      raise AuthenticationError.new("API key is not set for #{self.app_name}.") unless @api_key

      begin
        response = RestClient::Request.execute(method: method, url: api_url, payload: params.to_json, headers: self.request_headers)

        if response != ''
          JSON.parse(response)
        end
      rescue RestClient::ExceptionWithResponse => e
        if response_code = e.http_code and response_body = e.http_body
          handle_api_error(response_code, JSON.parse(response_body))
        else
          handle_restclient_error(e)
        end
      rescue RestClient::Exception, Errno::ECONNREFUSED => e
        handle_restclient_error(e)
      end
    end

    protected
      def app_name
        @app_name ||= Utils.demodulize(self.name)
      end

      def request_headers
        {
          Authorization: "Basic #{self.encoded_api_key}",
          content_type: :json,
          accept: :json
        }
      end

      def encoded_api_key
        @encoded_api_key ||= Base64.urlsafe_encode64(@api_key)
      end

      def handle_api_error(code, body)
        case code
        when 400, 404
          raise InvalidRequestError.new(body["message"])
        when 401
          raise AuthenticationError.new(body["message"])
        else
          raise ApiError.new(body["message"])
        end
      end

      def handle_restclient_error(e)
        case e
        when RestClient::ServerBrokeConnection
          message = "The connection with #{app_name} terminated before the request completed."
        else
          message = "Could not connect to #{app_name}."
        end

        raise ConnectionError.new(message)
      end
  end
end
