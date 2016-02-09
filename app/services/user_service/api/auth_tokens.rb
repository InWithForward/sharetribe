module UserService::API
  module AuthTokens

    module_function

    # Creates a token and returns the token string
    def create_login_token(user_id, options = {})
      attributes = {
        person_id: user_id,
        token_type: 'login',
        expires_at: 10.minutes.from_now
      }
      auth_token = AuthToken.create!(attributes.merge(options))

      { token: auth_token.token }
    end

    def use_token_for_login(token_string)
      return if token_string.blank?
      return unless t = AuthToken.where(token: token_string).first

      t.last_use_attempt = Time.now # record the usage attempt

      if t.expires_at > Time.now && t.token_type == "login"
        # Token is valid for login
        t.save
        return UserService::API::Users::from_model(t.person)
      end
    end

  end
end
