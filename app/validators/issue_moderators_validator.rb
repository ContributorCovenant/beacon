class IssueModeratorsValidator < ActiveModel::Validator

  def validate(record)
    return if record.blocked_moderator_ids.nil? || record.blocked_moderator_ids.empty?
    ids = record.blocked_moderator_ids.reject(&:empty?)
    project = Project.find(record.project_id)
    if ids.size == project.all_moderators.size
      record.errors[:blocked_moderators] << "must leave at least one moderator unblocked."
    end
    record.errors
  end

end
