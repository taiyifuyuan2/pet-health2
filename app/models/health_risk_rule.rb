# frozen_string_literal: true

class HealthRiskRule < ApplicationRecord
  validates :trigger_conditions, presence: true
  validates :message, presence: true
  validates :priority, presence: true, numericality: { greater_than: 0 }

  scope :by_priority, -> { order(:priority) }

  # ペットに適用されるかどうかをチェック
  def applies_to?(pet)
    return false unless trigger_conditions.is_a?(Hash)

    conditions = trigger_conditions

    # 犬種チェック
    return false if conditions['breed_names'].present? && !conditions['breed_names'].include?(pet.breed&.name)

    # 年齢チェック
    if conditions['age_months'].present?
      pet_age_months = pet.age_in_months
      age_range = conditions['age_months']

      if age_range.is_a?(Hash)
        min_age = age_range['min'] || 0
        max_age = age_range['max'] || Float::INFINITY
        return false unless pet_age_months >= min_age && pet_age_months <= max_age
      end
    end

    # 体重チェック
    if conditions['weight_kg'].present? && pet.weight_kg.present?
      weight_range = conditions['weight_kg']

      if weight_range.is_a?(Hash)
        min_weight = weight_range['min'] || 0
        max_weight = weight_range['max'] || Float::INFINITY
        return false unless pet.weight_kg >= min_weight && pet.weight_kg <= max_weight
      end
    end

    true
  end
end
