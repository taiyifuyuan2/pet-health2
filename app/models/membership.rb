# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :household

  # enum :role, { owner: 0, editor: 1, viewer: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :household_id }

  def owner?
    role == 'owner' || role == '0'
  end

  def editor?
    role == 'editor' || role == '1'
  end

  def viewer?
    role == 'viewer' || role == '2'
  end
end
