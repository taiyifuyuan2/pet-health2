class NotificationSetting < ApplicationRecord
  belongs_to :user

  validates :email_enabled, inclusion: { in: [true, false] }
  validates :line_notify_enabled, inclusion: { in: [true, false] }
  validates :reminder_advance_days, presence: true, inclusion: { in: [1, 2, 3, 7] }

  after_initialize :set_defaults

  private

  def set_defaults
    self.email_enabled = true if email_enabled.nil?
    self.line_notify_enabled = false if line_notify_enabled.nil?
    self.reminder_advance_days = 1 if reminder_advance_days.nil?
  end
end
