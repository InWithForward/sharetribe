if APP_CONFIG.use_exception_notifier
  ExceptionNotifier = Bugsnag

  ExceptionNotifier.configure do |config|
    config.api_key = APP_CONFIG.exception_notifier_api_key
  end
end
