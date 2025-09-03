# frozen_string_literal: true

class Breed < ApplicationRecord
  has_many :pets, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :risk_tags, presence: true

  # 犬種のリスクタグを取得
  def risk_tags_for_age(age_months)
    return [] unless risk_tags.is_a?(Hash)

    risk_tags.select do |age_range, _tags|
      min_age, max_age = age_range.split('-').map(&:to_i)
      age_months >= min_age && (max_age.nil? || age_months <= max_age)
    end.values.flatten.uniq
  end
end
