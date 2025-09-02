class CreatePets < ActiveRecord::Migration[7.1]
  def change
    create_table :pets do |t|
      t.string :name
      t.string :species
      t.string :sex
      t.date :birthdate
      t.references :household, null: false, foreign_key: true
      t.string :profile_image

      t.timestamps
    end
  end
end
