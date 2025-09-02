class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :memberships, dependent: :destroy
  has_many :households, through: :memberships
  has_one :notification_setting, dependent: :destroy

  validates :name, presence: true

  def profile_image_url
    profile_image.present? ? profile_image : "https://ui-avatars.com/api/?name=#{name}&background=random&color=fff&size=200"
  end
end
