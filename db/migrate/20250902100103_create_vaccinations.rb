# frozen_string_literal: true

class CreateVaccinations < ActiveRecord::Migration[7.1]
  def change
    create_table :vaccinations do |t|
      t.references :pet, null: false, foreign_key: true
      t.references :vaccine, null: false, foreign_key: true
      t.date :due_on
      t.string :status
      t.datetime :completed_at

      t.timestamps
    end
  end
end
