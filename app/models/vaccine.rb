class Vaccine < ApplicationRecord
  has_many :vaccine_schedule_rules, dependent: :destroy
  has_many :vaccinations, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  
  # ワクチンのスケジュールルールを取得
  def schedule_rule
    vaccine_schedule_rules.first
  end
end
