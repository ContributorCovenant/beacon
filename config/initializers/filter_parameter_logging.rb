# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password,
  :issue_id,
  :email,
  :token,
  :account_id,
  :project_id,
  :temp_2fa_code,
  :confirmation_token,
  :reset_password_token,
  :confirmation_token,
  :id
]
