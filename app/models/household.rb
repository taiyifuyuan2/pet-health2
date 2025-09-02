class Household < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :pets, dependent: :destroy
  has_many :events, dependent: :destroy

  validates :name, presence: true
end
