class AddBreedAndWeightToPets < ActiveRecord::Migration[7.1]
  def change
え    add_reference :pets, :breed, null: true, foreign_key: true
    add_column :pets, :weight_kg, :decimal
  end
end
