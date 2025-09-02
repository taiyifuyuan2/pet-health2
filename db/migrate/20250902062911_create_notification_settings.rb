class CreateNotificationSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :email_enabled, default: true, null: false
      t.boolean :line_notify_enabled, default: false, null: false
      t.time :daily_digest_time

      t.timestamps
    end
  end
end
