# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :pet

  validates :notification_type, presence: true, inclusion: { in: %w[vaccination medication health_advice] }
  validates :title, presence: true
  validates :message, presence: true
  validates :scheduled_for, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending sent read] }

  scope :pending, -> { where(status: 'pending') }
  scope :sent, -> { where(status: 'sent') }
  scope :read, -> { where(status: 'read') }
  scope :due_today, -> { where(scheduled_for: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :due_soon, -> { where(scheduled_for: Date.current..7.days.from_now) }

  # 通知を送信済みにマーク
  def mark_as_sent!
    update!(status: 'sent')
  end

  # 通知を既読にマーク
  def mark_as_read!
    update!(status: 'read')
  end
end
