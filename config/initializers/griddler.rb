Griddler.configure do |config|
  config.processor_class = EmailProcessorService
  config.email_class = EmailReport
  config.processor_method = :process
  config.reply_delimiter = '-- REPLY ABOVE THIS LINE --'
  config.email_service = :mailgun
end
