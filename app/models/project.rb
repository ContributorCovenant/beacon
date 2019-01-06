class Project < ApplicationRecord

  validates_uniqueness_of :name
  validates_uniqueness_of :url
  validates_uniqueness_of :slug
  validates_presence_of :name, :url, :coc_url

  belongs_to :account
  has_one :project_setting

  before_create :set_slug
  after_create :make_settings

  def issues
    decrypted_issue_ids = self.issues_encrypted_ids.map{ |id| EncryptionService.decrypt(id) }
    @issues ||= Issue.where(id: decrypted_issue_ids)
  end

  def to_param
    self.slug
  end

  def public?
    self.project_setting.include_in_directory
  end

  private

  def set_slug
    self.slug = self.name.downcase.gsub(" ", "-")
  end

  # Eventually this will inherit from an org's project template
  def make_settings
    create_project_setting
  end

end
