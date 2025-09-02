class VaccineScheduleRule < ApplicationRecord
  belongs_to :vaccine
  
  validates :min_age_weeks, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :repeat_every_days, presence: true, numericality: { greater_than: 0 }
  validates :booster_times, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # ペットの年齢に基づいて次の接種日を計算
  def next_due_date(pet_birthdate, last_vaccination_date = nil)
    pet_age_weeks = ((Date.current - pet_birthdate) / 7).to_i
    
    if last_vaccination_date.nil?
      # 初回接種
      pet_birthdate + (min_age_weeks * 7).days
    else
      # 追加接種
      last_vaccination_date + repeat_every_days.days
    end
  end
end
