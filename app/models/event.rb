class Event < ApplicationRecord
  belongs_to :household
  belongs_to :subject, polymorphic: true

  enum kind: { vaccine: 0, medication: 1, checkup: 2, other: 3, birthday: 4 }
  enum status: { pending: 0, completed: 1, skipped: 2 }

  validates :title, presence: true
  validates :scheduled_on, presence: true
  validates :kind, presence: true

  scope :due_between, ->(from, to) { where(scheduled_on: from..to) }
  scope :pending, -> { where(status: :pending) }
  scope :completed, -> { where(status: :completed) }

  def due_at
    if scheduled_time.present?
      Time.zone.parse("#{scheduled_on} #{scheduled_time}")
    else
      Time.zone.parse("#{scheduled_on} 09:00")
    end
  end

  def complete!
    update!(status: :completed, completed_at: Time.current)
  end
end
