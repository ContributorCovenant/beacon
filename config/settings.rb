require 'dotenv'
require 'active_support/core_ext'
require 'mc-settings'

Setting.load(
  path: "#{Rails.root}/config/settings",
  files: [
    'default.yml'
  ]
)
