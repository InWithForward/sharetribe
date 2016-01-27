module Api
  class SessionsController < ActionController::Base
    prepend_before_filter :allow_params_authentication!, :only => :create
    respond_to :json

    # POST /api/sessions
    def create
      person = authenticate_person!
      auth_token = UserService::API::AuthTokens.create_login_token(person.id, expires_at: 2.years.from_now)

      render json: {
        data: {
          type: 'session',
          id: auth_token[:token],
          attributes: {
            person_id: person.id
          }
        }
      }
    end
  end
end
