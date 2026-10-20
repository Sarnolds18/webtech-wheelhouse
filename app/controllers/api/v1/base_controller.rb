module Api
  module V1
    # Every controller of the API inherits from this one, not from ApplicationController: no views, no
    # session, no CSRF token. Every answer is JSON, and every error has one shape: { "errors": [...] }.
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      # Raised by an action when the request asks for something that does not exist, such as a filter
      # value that is not a state. Its message is the error the client reads.
      class BadRequest < StandardError; end

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from ActionDispatch::Http::Parameters::ParseError, with: :body_not_json
      rescue_from BadRequest, with: :bad_request

      # The catch-all route at the end of the API's routes lands here: a path or a verb the API does not
      # have gets the same error shape as everything else.
      def route_not_found
        render_errors [ "No route matches #{request.method} #{request.path}" ], :not_found
      end

      private

      # The accounting program and the owner's script send "Authorization: Bearer <token>". The token is
      # in the encrypted credentials, and it is compared in constant time so the answer leaks nothing.
      def require_token
        return if authenticate_with_http_token { |token| valid_token?(token) }

        headers["WWW-Authenticate"] = 'Bearer realm="Wheelhouse"'
        render_errors [ "A valid token is required in the Authorization header, with the Bearer scheme" ],
                      :unauthorized
      end

      def valid_token?(token)
        expected = Rails.application.credentials.api_token
        expected.present? && ActiveSupport::SecurityUtils.secure_compare(token, expected)
      end

      # Every price in every document travels the same way: a string with two decimals, the exact value
      # of the decimal column (docs/api.md). A JSON number would go through a float.
      def money(amount)
        ActiveSupport::NumberHelper.number_to_rounded(amount, precision: 2)
      end

      def render_errors(messages, status)
        render json: { errors: messages }, status: status
      end

      def record_not_found(exception)
        model = (exception.model || "Record").underscore.humanize
        render_errors [ "#{model} #{exception.id} does not exist" ], :not_found
      end

      def parameter_missing(exception)
        render_errors [ "The body has no attributes of a #{exception.param}" ], :bad_request
      end

      def body_not_json
        render_errors [ "The body is not valid JSON" ], :bad_request
      end

      def bad_request(exception)
        render_errors [ exception.message ], :bad_request
      end
    end
  end
end
