# frozen_string_literal: true

class CreateBreeds < ActiveRecord::Migration[7.1]
  def change
    create_table :breeds do |t|
      t.string :name
      t.jsonb :risk_tags

      t.timestamps
    end
  end
end
