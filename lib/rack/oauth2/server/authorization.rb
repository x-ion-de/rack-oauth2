require 'rack/auth/abstract/handler'
require 'rack/oauth2/server/profile/abstract'
require 'rack/oauth2/server/profile/web_server'
require 'rack/oauth2/server/profile/user_agent'

module Rack
  module OAuth2
    module Server
      # == OAuth Client Profiles
      #
      # === Web Server
      # ==== Condition
      # response_type:: code
      #
      # === User Agent
      # ==== Condition
      # response_type:: token
      #
      class Authorization < Rack::Auth::AbstractHandler

        def call(env)
          request = Request.new(env)
          case request.profile
          when :web_server
            Profile::WebServer.new(@app, @realm, &@authenticator).call(env)
          when :user_agent
            Profile::UserAgent.new(@app, @realm, &@authenticator).call(env)
          else
            @app.call(env)
          end
        end

        private

        class Request < Rack::Request
          def profile
            if self.params['code']
              :web_server
            else
              case self.params['response_type']
              when 'code'
                :web_server
              when 'token'
                :user_agent
              when 'token_and_code'
                raise BadRequest.new(:unsupported_response_type, 'This profile is pending.')
              end
            end
          end
        end

      end
    end
  end
end