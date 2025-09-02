class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :event_type
      t.datetime :scheduled_at
      t.references :subject, polymorphic: true, null: false
      t.references :household, null: false, foreign_key: true

      t.timestamps
    end
  end
end
