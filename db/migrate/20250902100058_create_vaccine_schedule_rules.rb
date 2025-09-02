class CreateVaccineScheduleRules < ActiveRecord::Migration[7.1]
  def change
    create_table :vaccine_schedule_rules do |t|
      t.references :vaccine, null: false, foreign_key: true
      t.integer :min_age_weeks
      t.integer :repeat_every_days
      t.integer :booster_times

      t.timestamps
    end
  end
end
