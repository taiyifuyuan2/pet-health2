# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :household
  belongs_to :invited_by, class_name: 'User'

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: %w[owner editor viewer] }
  validates :expires_at, presence: true

  scope :active, -> { where(accepted_at: nil).where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  def expired?
    expires_at <= Time.current
  end

  def accepted?
    accepted_at.present?
  end

  def active?
    !expired? && !accepted?
  end
end
