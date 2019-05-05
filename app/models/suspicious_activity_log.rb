class SuspiciousActivityLog < ApplicationRecord

  def self.throttle(remote_ip)
    return unless where(ip_address: remote_ip, created_at: (DateTime.now - 5.minutes)..DateTime.now).count >= 10
    Rails.cache.write("block #{remote_ip}", true, expires_in: ENV.fetch('THROTTLE_MINUTES', 10).minutes)
  end
end
