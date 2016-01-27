module AuthTokenAuthenticatable

  def authenticate!
    user_to_log_in = UserService::API::AuthTokens.use_token_for_login(params[:auth])

    if user_to_log_in && person = Person.find(user_to_log_in[:id])
      sign_in person
    else
      render nothing: true, status: :unauthorized
      false
    end
  end

end
