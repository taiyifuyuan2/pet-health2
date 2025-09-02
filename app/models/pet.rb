class Pet < ApplicationRecord
  belongs_to :household
  has_many :events, as: :subject, dependent: :destroy

  validates :name, presence: true
  validates :species, presence: true

  # species: "dog", "cat", "other"
  # sex: "male", "female", "unknown"

  def profile_image_url
    profile_image.present? ? profile_image : "https://ui-avatars.com/api/?name=#{name}&background=random&color=fff&size=200"
  end
end
