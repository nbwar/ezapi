require 'rest-client'
require 'json'
require 'base64'
require 'uri'
require 'nokogiri'

module EZApi
  module Client
    attr_accessor :key, :base_url
    def self.extended(base)
      [:get, :post, :put, :patch, :delete].each do |method|
        define_method(method) do |path, params={}, headers=request_headers, request_arguments={}|
          full_path = full_api_path(path)
          request(full_path, method, params, headers, request_arguments)
        end
      end
    end

    def api_url(url)
      self.base_url = url
    end

    def api_key(key)
      self.key = key
    end

    def request(full_url, method, params={}, headers=self.request_headers, request_arguments={})
      response = raw_request(full_url, method, params, headers, request_arguments)

      begin
        if response.headers && response.headers[:content_type] == "application/xml"
          Nokogiri::XML(response.body)
        else
          JSON.parse(response.body) unless response.empty?
        end
      rescue JSON::ParserError => e
        nil
      end
    end

    def raw_request(full_url, method, params={}, headers=self.request_headers, request_arguments={})
      default_request = {method: method, url: full_url, payload: params, headers: headers}
      begin
        RestClient::Request.execute(default_request.merge(request_arguments))
      rescue RestClient::ExceptionWithResponse => e
        if response_code = e.http_code and response_body = e.http_body
          handle_api_error(response_code, response_body)
        else
          handle_restclient_error(e)
        end
      rescue RestClient::Exception, Errno::ECONNREFUSED, SocketError => e
        handle_restclient_error(e)
      end
    end

    protected
      def app_name
        self.name.demodulize
      end

      def full_api_path(path)
        File.join(base_url, path).to_s
      end

      def request_headers
        {
          Authorization: "Basic #{encoded_api_key}",
          content_type: :json,
          accept: :json
        }
      end

      def encoded_api_key
        raise(AuthenticationError, "API key is not set for #{self.app_name}.") unless self.key

        Base64.urlsafe_encode64(self.key)
      end

      def parse_error_message(raw_body)
        body = JSON.parse(raw_body)
        (body && body['error']) ? body['error']['message'] : 'An unknown error occured.'
      rescue
        'An unknown error occured.'
      end

      def handle_api_error(code, body)
        message = parse_error_message(body)
        case code
        when 400, 404, 422
          raise(InvalidRequestError.new(message, body: body, code: code ))
        when 401
          raise(AuthenticationError.new(message, body: body, code: code ))
        when 429
          raise(TooManyRequestsError.new(message, body: body, code: code ))
        else
          raise(ApiError.new(message, body: body, code: code ))
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
