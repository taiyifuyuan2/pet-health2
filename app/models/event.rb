class Event < ApplicationRecord
  belongs_to :household
  belongs_to :subject, polymorphic: true

  enum event_type: { vaccine: 0, medication: 1, checkup: 2, other: 3, birthday: 4 }
  enum status: { pending: 0, completed: 1, skipped: 2 }

  validates :title, presence: true
  validates :scheduled_at, presence: true
  validates :event_type, presence: true

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
