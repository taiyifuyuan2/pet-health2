# frozen_string_literal: true

class WalkLog < ApplicationRecord
  belongs_to :pet

  validates :date, presence: true, uniqueness: { scope: :pet_id }
  validates :distance_km, presence: true, numericality: { greater_than: 0 }
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :note, length: { maximum: 1000 }

  scope :recent, -> { order(date: :desc) }
  scope :for_period, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :this_week, -> { where(date: Date.current.beginning_of_week..Date.current.end_of_week) }
  scope :this_month, -> { where(date: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :last_30_days, -> { where(date: 30.days.ago..Date.current) }

  def self.total_distance(pet, period = :this_week)
    case period
    when :this_week
      pet.walk_logs.this_week.sum(:distance_km)
    when :this_month
      pet.walk_logs.this_month.sum(:distance_km)
    when :last_30_days
      pet.walk_logs.last_30_days.sum(:distance_km)
    else
      pet.walk_logs.sum(:distance_km)
    end
  end

  def self.total_duration(pet, period = :this_week)
    case period
    when :this_week
      pet.walk_logs.this_week.sum(:duration_minutes)
    when :this_month
      pet.walk_logs.this_month.sum(:duration_minutes)
    when :last_30_days
      pet.walk_logs.last_30_days.sum(:duration_minutes)
    else
      pet.walk_logs.sum(:duration_minutes)
    end
  end

  def self.average_distance(pet, period = :this_week)
    total = total_distance(pet, period)
    count = case period
            when :this_week
              pet.walk_logs.this_week.count
            when :this_month
              pet.walk_logs.this_month.count
            when :last_30_days
              pet.walk_logs.last_30_days.count
            else
              pet.walk_logs.count
            end
    count.positive? ? (total / count).round(1) : 0
  end

  def self.average_duration(pet, period = :this_week)
    total = total_duration(pet, period)
    count = case period
            when :this_week
              pet.walk_logs.this_week.count
            when :this_month
              pet.walk_logs.this_month.count
            when :last_30_days
              pet.walk_logs.last_30_days.count
            else
              pet.walk_logs.count
            end
    count.positive? ? (total / count).round(0) : 0
  end

  def duration_hours
    (duration_minutes / 60.0).round(1)
  end

  def pace_per_km
    return 0 if distance_km.zero?

    (duration_minutes / distance_km).round(1)
  end
end
