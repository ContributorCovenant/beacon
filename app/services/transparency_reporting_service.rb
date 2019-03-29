class TransparencyReportingService

  attr_reader :project

  FEATURES = [:fairness, :responsiveness, :sensitivity, :community].freeze

  def initialize(project)
    @project = project
  end

  def average_time_to_resolution
    resolved_issues = project.issues.resolved + project.issues.dismissed
    return nil unless resolved_issues.any?
    resolution_days = resolved_issues.map do |i|
      next unless i.closed_at
      (i.closed_at - i.created_at).to_f / 1.day
    end.compact
    return unless resolution_days.any?
    (resolution_days.sum / resolution_days.size).to_i
  end

  def health
    return "Not enough data" unless raw_scores.values.compact.any?
    label(raw_scores.values.compact.sum / raw_scores.values.compact.size)
  end

  def labelled_scores
    raw_scores.inject({}) do |h, tuple|
      h[tuple[0]] = label(tuple[1])
      h
    end
  end

  def suitable_for_public?
    reporter_surveys.size >= 2
  end

  def net_promoter_score
    scores = reporter_surveys.map(&:would_recommend).compact
    detractors = scores.select{ |s| s < 7 }
    promoters = scores.select{ |s| s >= 7 }
    detractors_percentage = detractors.size / scores.size.to_f
    promoters_percentage = promoters.size / scores.size.to_f
    case promoters_percentage - detractors_percentage
    when 0...0.1
      "Poor"
    when 0.1...0.5
      "Good"
    when 0.5...0.7
      "Excellent"
    when 0.7..1.0
      "Exceptional"
    else
      "Not enough data"
    end
  end

  private

  def calculate_score(feature)
    return nil if reporter_surveys.empty?
    reporter_percentage = reporter_surveys.map(&feature).compact.sum{ |f| f ? 1 : 0 } / reporter_surveys.size.to_f
    if respondent_surveys.any?
      respondent_percentage = respondent_surveys.map(&feature).compact.sum{ |f| f ? 1 : 0 } / reporter_surveys.size.to_f
    else
      respondent_percentage = 1
    end
    (reporter_percentage * 0.75) + (respondent_percentage * 0.25)
  end

  def label(score)
    case score
    when nil
      "Not enough data"
    when 0.0..0.4
      "Poor"
    when 0.4..0.74
      "Good"
    else
      "Excellent"
    end
  end

  def raw_scores
    return @raw_scores if @raw_scores
    @raw_scores = FEATURES.inject({}) do |h, feature|
      h[feature] = calculate_score(feature)
      h
    end
    @raw_scores
  end

  def reporter_surveys
    @reporter_surveys ||= project.surveys.reporter
  end

  def respondent_surveys
    @respondent_surveys ||= project.surveys.respondent
  end

  def total_surveys
    reporter_surveys.size + respondent_surveys.size
  end

end
