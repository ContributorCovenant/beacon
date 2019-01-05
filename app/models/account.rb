require 'digest'
require 'normailize'

class Account < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  devise :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
         :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable

  validates_uniqueness_of :normalized_email

  has_many :projects

  before_create :normalize_email
  before_create :hash_email

  private

  def hash_email
    self.hashed_email = Digest::MD5.hexdigest(self.normalized_email)
  end

  def normalize_email
    normalized = Normailize::EmailAddress.new(self.email).normalized_address
    self.normalized_email = normalized.gsub(/\+.+\@/, "@")
  end

end
