# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :household
  belongs_to :subject, polymorphic: true

  enum event_type: { vaccine: 0, medication: 1, checkup: 2, other: 3, birthday: 4 }
  enum status: { pending: 0, completed: 1, skipped: 2 }

  validates :title, presence: true
  validates :scheduled_at, presence: true
  validates :event_type, presence: true

  after_initialize :set_default_status, if: :new_record?

  # 仮想属性（フォーム用）
  attr_accessor :kind, :note, :scheduled_on, :scheduled_time

  # 仮想属性のゲッター
  def kind
    @kind || event_type
  rescue => e
    Rails.logger.error "Error getting kind for event #{id}: #{e.message}"
    nil
  end

  def note
    @note || description
  rescue => e
    Rails.logger.error "Error getting note for event #{id}: #{e.message}"
    nil
  end

  def scheduled_on
    @scheduled_on || (scheduled_at&.to_date)
  rescue => e
    Rails.logger.error "Error getting scheduled_on for event #{id}: #{e.message}"
    nil
  end

  def scheduled_time
    @scheduled_time || (scheduled_at&.to_time)
  rescue => e
    Rails.logger.error "Error getting scheduled_time for event #{id}: #{e.message}"
    nil
  end

  private

  def set_default_status
    self.status ||= :pending
  end



  scope :due_between, ->(from, to) { where(scheduled_at: from..to) }
  scope :pending, -> { where(status: :pending) }
  scope :completed, -> { where(status: :completed) }

  def due_at
    scheduled_at
  end

  def complete!
    update_column(:status, 'completed')
    update_column(:completed_at, Time.current)
  end
end
