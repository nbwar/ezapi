require 'rest-client'
require 'json'
require 'base64'
require 'uri'

module EZApi
  module Client
    attr_accessor :key, :base_url

    def self.extended(base)
      [:get, :post, :put, :patch, :delete].each do |method|
        define_method(method) do |path, params = {}|
          full_path = full_api_path(path)
          request(full_path, method, params)
        end
      end
    end

    def api_url(url)
      self.base_url = url
    end

    def api_key(key)
      self.key = key
    end

    def request(full_url, method, params={})
      raise(AuthenticationError, "API key is not set for #{self.app_name}.") unless self.key

      begin
        response = RestClient::Request.execute(method: method, url: full_url, payload: params.to_json, headers: request_headers)
        JSON.parse(response) unless response.empty?
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
        self.name.demodulize
      end

      def full_api_path(path)
        URI.join(base_url, path).to_s
      end

      def request_headers
        {
          Authorization: "Basic #{encoded_api_key}",
          content_type: :json,
          accept: :json
        }
      end

      def encoded_api_key
        Base64.urlsafe_encode64(self.key)
      end

      def parse_error_message(body)
        body['message']
      end

      def handle_api_error(code, body)
        message = parse_error_message(body)
        case code
        when 400, 404
          raise(InvalidRequestError, message)
        when 401
          raise(AuthenticationError, message)
        else
          raise(ApiError, message)
        end
      end

      def handle_restclient_error(e)
        case e
        when RestClient::ServerBrokeConnection
          message = "The connection with #{app_name} terminated before the request completed."
        else
          message = "Could not connect to #{app_name}."
        end

        raise(ConnectionError, message)
      end
  end
end
