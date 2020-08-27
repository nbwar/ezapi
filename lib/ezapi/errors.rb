module EZApi
  class EZApiError < StandardError
    attr_reader :body, :code
    def initialize(message = nil, body: nil, code: nil )
      @body = body
      @code = code
      super(message)
    end
  end
  class AuthenticationError < EZApiError; end
  class InvalidRequestError < EZApiError; end
  class TooManyRequestsError < EZApiError; end
  class ConnectionError < EZApiError; end
  class ApiError < EZApiError; end
end
