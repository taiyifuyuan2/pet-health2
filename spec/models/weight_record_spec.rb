# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeightRecord, type: :model do
  describe 'associations' do
    it { should belong_to(:pet) }
  end

  describe 'validations' do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:weight_kg) }
    it { should validate_numericality_of(:weight_kg).is_greater_than(0) }
    it { should validate_length_of(:note).is_at_most(1000) }

    it 'validates uniqueness of date scoped to pet' do
      pet = create(:pet)
      create(:weight_record, pet: pet, date: Date.current)
      duplicate_record = build(:weight_record, pet: pet, date: Date.current)

      expect(duplicate_record).not_to be_valid
      expect(duplicate_record.errors[:date]).to include('has already been taken')
    end
  end

  describe 'scopes' do
    let(:pet) { create(:pet) }

    before do
      create(:weight_record, pet: pet, date: 10.days.ago)
      create(:weight_record, pet: pet, date: 5.days.ago)
      create(:weight_record, pet: pet, date: Date.current)
    end

    describe '.recent' do
      it 'orders by date descending' do
        records = pet.weight_records.recent
        expect(records.first.date).to eq(Date.current)
        expect(records.last.date).to eq(10.days.ago.to_date)
      end
    end

    describe '.last_30_days' do
      it 'returns records from last 30 days' do
        create(:weight_record, pet: pet, date: 35.days.ago)
        records = pet.weight_records.last_30_days
        expect(records.count).to eq(3)
      end
    end
  end

  describe '.chart_data' do
    let(:pet) { create(:pet) }

    before do
      create(:weight_record, pet: pet, date: 5.days.ago, weight_kg: 10.0)
      create(:weight_record, pet: pet, date: Date.current, weight_kg: 10.5)
    end

    it 'returns chart data in correct format' do
      data = WeightRecord.chart_data(pet, :last_30_days)
      expect(data).to be_an(Array)
      expect(data.first).to eq([5.days.ago.strftime('%m/%d'), 10.0])
      expect(data.last).to eq([Date.current.strftime('%m/%d'), 10.5])
    end
  end

  describe '.latest_weight' do
    let(:pet) { create(:pet) }

    it 'returns the most recent weight' do
      create(:weight_record, pet: pet, date: 5.days.ago, weight_kg: 10.0)
      create(:weight_record, pet: pet, date: Date.current, weight_kg: 10.5)

      expect(WeightRecord.latest_weight(pet)).to eq(10.5)
    end

    it 'returns nil if no records exist' do
      expect(WeightRecord.latest_weight(pet)).to be_nil
    end
  end

  describe '.weight_change' do
    let(:pet) { create(:pet) }

    it 'calculates weight change over specified period' do
      create(:weight_record, pet: pet, date: 30.days.ago, weight_kg: 10.0)
      create(:weight_record, pet: pet, date: Date.current, weight_kg: 10.5)

      expect(WeightRecord.weight_change(pet, 30)).to eq(0.5)
    end

    it 'returns nil if insufficient data' do
      create(:weight_record, pet: pet, date: Date.current, weight_kg: 10.5)

      expect(WeightRecord.weight_change(pet, 30)).to be_nil
    end
  end
end
