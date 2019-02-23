class Organization < ApplicationRecord
  validates_uniqueness_of :name
  validates_uniqueness_of :slug
  validates_presence_of :name

  belongs_to :account
  has_many :roles
  has_many :moderators, through: :roles, source: :account
  has_many :projects

  before_create :set_slug

  def default_moderators
    roles.where(is_default_moderator: true).map(&:account)
  end

  def owner?(account)
    roles.where(is_owner: true, account_id: account.id).any?
  end

  def moderator?(account)
    moderators.include?(account)
  end

  def moderator_emails
    moderators.map(&:email)
  end

  def to_param
    slug
  end

  def flagged?
    !self.flagged_at.nil?
  end

  def flag!
    self.update_attribute(:flagged_at, DateTime.now)
  end

  def unflag!
    self.update_attribute(:flagged_at, nil)
  end

  def toggle_flagged
    flagged? ? unflag! : flag!
  end

  private

  def set_slug
    self.slug = name.downcase.gsub(/[^a-z0-9]/i, '_')
  end

end
