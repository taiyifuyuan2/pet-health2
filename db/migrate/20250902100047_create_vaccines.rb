# frozen_string_literal: true

class CreateVaccines < ActiveRecord::Migration[7.1]
  def change
    create_table :vaccines do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
