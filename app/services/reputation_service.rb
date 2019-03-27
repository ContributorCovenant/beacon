class ReputationService

  WEIGHTED_ACTIVITIES = {
    issues_dismissed: 0.1,
    issues_marked_spam: 0.2,
    times_blocked: 0.2,
    times_flagged: 0.5,
  }.freeze

  REPUTATIONS = {
    unknown: 0,
    good: 10,
    medium: 20,
    poor: 30
  }.freeze

  def self.reputation(activities)
    sum = WEIGHTED_ACTIVITIES.keys.sum{ |k| activities.send(k) }
    score = WEIGHTED_ACTIVITIES.sum do |activity, weight|
      activities.send(activity) / WEIGHTED_ACTIVITIES.size.to_f * weight
    end
    (score / sum * 100).to_i
#    (score / WEIGHTED_ACTIVITIES.size * 100).to_i
  end

end

# h = Hashie::Mash.new(issues_dismissed: 10, issues_marked_spam: 0, times_blocked: 0, times_flagged: 0)
# ReputationService.reputation(h)
