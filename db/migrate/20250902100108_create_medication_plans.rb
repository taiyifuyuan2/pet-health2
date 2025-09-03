# frozen_string_literal: true

class CreateMedicationPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :medication_plans do |t|
      t.string :name
      t.decimal :dosage_mg_per_kg
      t.integer :interval_days
      t.date :season_from
      t.date :season_to

      t.timestamps
    end
  end
end
