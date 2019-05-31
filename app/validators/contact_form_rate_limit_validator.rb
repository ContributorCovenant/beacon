class ContactFormRateLimitValidator < ActiveModel::Validator

  def validate(record)
    return true if messages_count(record) < max_general_contacts_per_day

    record.errors[:limit] << "of messages you can send has been reached."
  end

  private

  def messages_count(record)
    ContactMessage.past_24_hours.for_ip(record.sender_ip).count
  end

  def max_general_contacts_per_day
    Setting.throttling(:max_general_contacts_per_day)
  end

end
