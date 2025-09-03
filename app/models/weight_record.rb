class WeightRecord < ApplicationRecord
  belongs_to :pet

  validates :date, presence: true, uniqueness: { scope: :pet_id }
  validates :weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :note, length: { maximum: 1000 }

  scope :recent, -> { order(date: :desc) }
  scope :for_period, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :last_30_days, -> { where(date: 30.days.ago..Date.current) }
  scope :last_6_months, -> { where(date: 6.months.ago..Date.current) }

  def self.chart_data(pet, period = :last_30_days)
    records = case period
              when :last_30_days
                pet.weight_records.last_30_days.order(:date)
              when :last_6_months
                pet.weight_records.last_6_months.order(:date)
              else
                pet.weight_records.recent.limit(30)
              end

    records.map { |record| [record.date.strftime('%m/%d'), record.weight_kg.to_f] }
  end

  def self.latest_weight(pet)
    pet.weight_records.recent.first&.weight_kg
  end

  def self.weight_change(pet, days = 30)
    recent = pet.weight_records.where(date: days.days.ago..Date.current).order(:date)
    return nil if recent.count < 2

    latest = recent.last.weight_kg
    oldest = recent.first.weight_kg
    latest - oldest
  end
end
