#BackwardCompatibleExNotifier.email_prefix = "[ERROR-WellTreat.Us] "
#BackwardCompatibleExNotifier.exception_recipients = %w(hasan@welltreat.us)
#BackwardCompatibleExNotifier.sender_address =
#    %("Application Error" <app.error@welltreat.us>)
ExceptionNotification::Notifier.configure_exception_notifier do |config|
  config[:app_name] = "[WellTreatUs]"
  config[:sender_address] = "support@welltreat.us"
  config[:exception_recipients] = ['exceptions@welltreat.us']
  config[:notify_error_codes] = %W( 405 500 503 )
  config[:notify_other_errors] = true

end

