module DelayedExceptionNotification

  def error(job, exception)
    ExceptionNotifier.notify(exception) if APP_CONFIG.use_exception_notifier
  end

end
