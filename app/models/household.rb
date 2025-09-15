# frozen_string_literal: true

class Household < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :pets, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :invitations, dependent: :destroy

  validates :name, presence: true

  def owner
    memberships.find_by(role: 'owner')&.user
  end

  def editors
    users.joins(:memberships).where(memberships: { role: 'editor' })
  end

  def viewers
    users.joins(:memberships).where(memberships: { role: 'viewer' })
  end
end
