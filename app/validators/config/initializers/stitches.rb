require 'stitches'

Stitches.configure do |configuration|
  configuration.allowlist_regexp = %r{\A/(resque|docs|assets|proof_of_life)(\Z|/.*\Z)}
  configuration.custom_http_auth_scheme = "StitchFixInternal"
end