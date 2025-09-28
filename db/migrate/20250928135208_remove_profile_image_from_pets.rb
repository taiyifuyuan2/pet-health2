class RemoveProfileImageFromPets < ActiveRecord::Migration[7.1]
  def change
    remove_column :pets, :profile_image, :string
  end
end
