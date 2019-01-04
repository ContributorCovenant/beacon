class Project < ApplicationRecord

  validates_uniqueness_of :name
  validates_uniqueness_of :url
  validates_uniqueness_of :slug
  validates_presence_of :name, :url, :coc_url

  belongs_to :account

  before_create :set_slug

  def to_param
    self.slug
  end

  private

  def set_slug
    self.slug = self.name.downcase.gsub(" ", "-")
  end

end
