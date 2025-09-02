class Pet < ApplicationRecord
  belongs_to :household
  belongs_to :breed, optional: true
  has_many :events, as: :subject, dependent: :destroy
  has_many :vaccinations, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :name, presence: true
  validates :species, presence: true
  validates :weight_kg, numericality: { greater_than: 0 }, allow_nil: true

  # species: "dog", "cat", "other"
  # sex: "male", "female", "unknown"

  def profile_image_url
    profile_image.present? ? profile_image : "https://ui-avatars.com/api/?name=#{name}&background=random&color=fff&size=200"
  end
  
  # ペットの年齢を月単位で取得
  def age_in_months
    return 0 unless birthdate.present?
    
    ((Date.current - birthdate) / 30.44).to_i
  end
  
  # ペットの年齢を週単位で取得
  def age_in_weeks
    return 0 unless birthdate.present?
    
    ((Date.current - birthdate) / 7).to_i
  end
  
  # 今日の予定を取得
  def todays_schedule
    vaccinations.due_today
  end
  
  # 今週の予定を取得
  def this_weeks_schedule
    vaccinations.due_soon
  end
  
  # 健康アドバイスを取得
  def health_advice
    HealthRiskRule.by_priority.select { |rule| rule.applies_to?(self) }
  end
end
