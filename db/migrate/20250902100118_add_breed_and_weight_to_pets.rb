class AddBreedAndWeightToPets < ActiveRecord::Migration[7.1]
  def change
    add_reference :pets, :breed, null: false, foreign_key: true
    add_column :pets, :weight_kg, :decimal
  end
end
