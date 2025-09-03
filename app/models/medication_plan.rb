# frozen_string_literal: true

class MedicationPlan < ApplicationRecord
  validates :name, presence: true
  validates :dosage_mg_per_kg, presence: true, numericality: { greater_than: 0 }
  validates :interval_days, presence: true, numericality: { greater_than: 0 }

  # 季節性の薬かどうか
  def seasonal?
    season_from.present? && season_to.present?
  end

  # 現在の季節に適用されるかどうか
  def applicable_now?
    return true unless seasonal?

    current_date = Date.current
    current_year = current_date.year

    # 年をまたぐ場合の処理
    if season_from > season_to
      current_date >= season_from.change(year: current_year) ||
        current_date <= season_to.change(year: current_year)
    else
      current_date >= season_from.change(year: current_year) &&
        current_date <= season_to.change(year: current_year)
    end
  end

  # ペットの体重に基づいて投薬量を計算
  def dosage_for_pet(pet_weight_kg)
    (dosage_mg_per_kg * pet_weight_kg).round(2)
  end
end
