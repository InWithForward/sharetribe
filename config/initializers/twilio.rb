Twilio.configure do |config|
  config.account_sid = APP_CONFIG.twilio_account_sid
  config.auth_token = APP_CONFIG.twilio_auth_token
end
