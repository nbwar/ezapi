module EZApi
  class EZApiError < StandardError;end
  class AuthenticationError < EZApiError; end
  class InvalidRequestError < EZApiError; end
  class ConnectionError < EZApiError; end
  class ApiError < EZApiError; end
end
