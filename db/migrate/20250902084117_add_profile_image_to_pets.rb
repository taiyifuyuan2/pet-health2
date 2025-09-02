class AddProfileImageToPets < ActiveRecord::Migration[7.1]
  def change
    add_column :pets, :profile_image, :string
  end
end
