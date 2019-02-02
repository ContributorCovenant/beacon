class ContactFormRateLimitValidator < ActiveModel::Validator

  def validate(record)
    return true if ContactMessage.past_24_hours.for_ip(record.sender_ip).count < Setting.throttling(:max_general_contacts_per_day)
    record.errors[:limit] << "of messages you can send has been reached."
  end

end
