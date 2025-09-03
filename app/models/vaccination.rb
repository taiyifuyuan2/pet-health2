# frozen_string_literal: true

class Vaccination < ApplicationRecord
  belongs_to :pet
  belongs_to :vaccine

  validates :due_on, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending completed missed] }

  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :missed, -> { where(status: 'missed') }
  scope :due_today, -> { where(due_on: Date.current) }
  scope :due_soon, -> { where(due_on: Date.current..7.days.from_now) }

  # 接種完了
  def complete!
    update!(status: 'completed', completed_at: Time.current)
  end

  # 期限切れチェック
  def overdue?
    status == 'pending' && due_on < Date.current
  end
end
