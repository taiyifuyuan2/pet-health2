class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :household, null: false, foreign_key: true
      t.references :subject, polymorphic: true, null: false
      t.integer :kind, null: false
      t.string :title, null: false
      t.date :scheduled_on, null: false
      t.time :scheduled_time
      t.string :rrule
      t.integer :remind_before_minutes, default: 1440, null: false
      t.integer :status, default: 0, null: false
      t.datetime :completed_at
      t.text :note

      t.timestamps
    end

    add_index :events, [:household_id, :scheduled_on]
    add_index :events, [:subject_type, :subject_id]
    add_index :events, :kind
  end
end
