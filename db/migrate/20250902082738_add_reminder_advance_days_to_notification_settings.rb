class AddReminderAdvanceDaysToNotificationSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_settings, :reminder_advance_days, :integer
  end
end
