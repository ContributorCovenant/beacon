class EventValidator < ActiveModel::Validator

  def validate(record)
    return true unless record.is_event?
    record.errors[:duration] << "must be entered." if record.duration.nil?
    record.errors[:attendees] << "must be selected." if record.attendees.nil?
    record.errors[:frequency] << "must be selected." if record.frequency.nil?
    record.errors
  end

end
