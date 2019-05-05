class Rack::Attack

  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/accounts/sign_in' && req.post?
      req.ip
    end
  end

  blocklist("block ip") do |req|
    Rails.cache.read("block #{req.ip}")
  end

  denied = ENV.fetch('RACKATTACK_DENY', "").split(/,\s*/)
  denied_regexp = Regexp.union(denied)
  blocklist("refspam") do |request|
    request.referer =~ denied_regexp
  end

  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == '/accounts/sign_in' && req.post?
      req.params['email'].presence
    end
  end

  self.throttled_response = lambda do
    [ENV.fetch('THROTTLED_RESPONSE_CODE', 418), {}, ['']]
  end
end
