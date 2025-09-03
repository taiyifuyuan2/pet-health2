class CreateWalkLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :walk_logs do |t|
      t.references :pet, null: false, foreign_key: true
      t.date :date, null: false
      t.decimal :distance_km, precision: 5, scale: 1, null: false
      t.integer :duration_minutes, null: false
      t.text :note

      t.timestamps
    end

    add_index :walk_logs, [:pet_id, :date], unique: true
  end
end
