class ContactMessage < ApplicationRecord

  validates_presence_of :message
  validates_presence_of :sender_email
  validates_with ContactFormRateLimitValidator

  scope :past_24_hours, -> { where("created_at >= ?", Time.zone.now - 24.hours) }
  scope :for_ip, ->(ip_address) { where(sender_ip: ip_address) }

end
