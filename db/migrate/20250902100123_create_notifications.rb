class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :notification_type
      t.string :title
      t.text :message
      t.datetime :scheduled_for
      t.string :status

      t.timestamps
    end
  end
end
