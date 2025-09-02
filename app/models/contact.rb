class Contact < ApplicationRecord
  belongs_to :household
  has_many :events, as: :subject, dependent: :destroy

  validates :name, presence: true
  validates :birthday, presence: true

  # relation: "friend", "family", "other"
end
