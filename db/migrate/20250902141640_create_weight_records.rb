class CreateWeightRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :weight_records do |t|
      t.references :pet, null: false, foreign_key: true
      t.date :date, null: false
      t.decimal :weight_kg, precision: 5, scale: 1, null: false
      t.text :note

      t.timestamps
    end

    add_index :weight_records, [:pet_id, :date], unique: true
  end
end
