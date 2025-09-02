class CreatePets < ActiveRecord::Migration[7.1]
  def change
    create_table :pets do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.string :species, null: false
      t.string :sex
      t.date :birthday
      t.text :notes

      t.timestamps
    end
  end
end
