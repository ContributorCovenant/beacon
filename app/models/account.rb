# frozen_string_literal: true

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
  has_many :account_issues

  before_create :normalize_email
  before_create :hash_email

  def issues
    @issues ||= AccountIssue.issues_for_account(self.id)
  end

  private

  def hash_email
    self.hashed_email = Digest::MD5.hexdigest(normalized_email)
  end

  def normalize_email
    normalized = Normailize::EmailAddress.new(email).normalized_address
    self.normalized_email = normalized.gsub(/\+.+\@/, '@')
  end
end
