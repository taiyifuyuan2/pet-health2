class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.references :household, null: false, foreign_key: true
      t.string :email
      t.string :token
      t.string :role
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.datetime :accepted_at
      t.datetime :expires_at

      t.timestamps
    end
  end
end
