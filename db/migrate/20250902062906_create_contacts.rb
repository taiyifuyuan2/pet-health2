class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.date :birthday, null: false
      t.string :relation
      t.text :notes

      t.timestamps
    end
  end
end
