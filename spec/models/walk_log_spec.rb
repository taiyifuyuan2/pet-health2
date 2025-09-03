require 'rails_helper'

RSpec.describe WalkLog, type: :model do
  describe 'associations' do
    it { should belong_to(:pet) }
  end

  describe 'validations' do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:distance_km) }
    it { should validate_presence_of(:duration_minutes) }
    it { should validate_numericality_of(:distance_km).is_greater_than(0) }
    it { should validate_numericality_of(:duration_minutes).is_greater_than(0) }
    it { should validate_length_of(:note).is_at_most(1000) }
    
    it 'validates uniqueness of date scoped to pet' do
      pet = create(:pet)
      create(:walk_log, pet: pet, date: Date.current)
      duplicate_log = build(:walk_log, pet: pet, date: Date.current)
      
      expect(duplicate_log).not_to be_valid
      expect(duplicate_log.errors[:date]).to include('has already been taken')
    end
  end

  describe 'scopes' do
    let(:pet) { create(:pet) }
    
    before do
      create(:walk_log, pet: pet, date: 10.days.ago.to_date)
      create(:walk_log, pet: pet, date: 5.days.ago.to_date)
      create(:walk_log, pet: pet, date: Date.current)
    end

    describe '.recent' do
      it 'orders by date descending' do
        logs = pet.walk_logs.recent
        expect(logs.first.date).to eq(Date.current)
        expect(logs.last.date).to eq(10.days.ago.to_date)
      end
    end

    describe '.this_week' do
      it 'returns records from this week' do
        logs = pet.walk_logs.this_week
        expect(logs.count).to eq(1) # only today (5 days ago is outside this week)
      end
    end
  end

  describe '.total_distance' do
    let(:pet) { create(:pet) }
    
    before do
      create(:walk_log, pet: pet, date: 5.days.ago.to_date, distance_km: 2.0)
      create(:walk_log, pet: pet, date: Date.current, distance_km: 3.0)
      create(:walk_log, pet: pet, date: 10.days.ago.to_date, distance_km: 1.0)
    end

    it 'calculates total distance for this week' do
      expect(WalkLog.total_distance(pet, :this_week)).to eq(3.0)
    end

    it 'calculates total distance for this month' do
      expect(WalkLog.total_distance(pet, :this_month)).to eq(3.0)
    end
  end

  describe '.total_duration' do
    let(:pet) { create(:pet) }
    
    before do
      create(:walk_log, pet: pet, date: 5.days.ago.to_date, duration_minutes: 30)
      create(:walk_log, pet: pet, date: Date.current, duration_minutes: 45)
      create(:walk_log, pet: pet, date: 10.days.ago.to_date, duration_minutes: 20)
    end

    it 'calculates total duration for this week' do
      expect(WalkLog.total_duration(pet, :this_week)).to eq(45)
    end

    it 'calculates total duration for this month' do
      expect(WalkLog.total_duration(pet, :this_month)).to eq(45)
    end
  end

  describe '.average_distance' do
    let(:pet) { create(:pet) }
    
    before do
      create(:walk_log, pet: pet, date: 5.days.ago.to_date, distance_km: 2.0)
      create(:walk_log, pet: pet, date: Date.current, distance_km: 4.0)
    end

    it 'calculates average distance for this week' do
      expect(WalkLog.average_distance(pet, :this_week)).to eq(4.0)
    end

    it 'returns 0 if no records exist' do
      new_pet = create(:pet)
      expect(WalkLog.average_distance(new_pet, :this_week)).to eq(0)
    end
  end

  describe '#duration_hours' do
    it 'converts minutes to hours' do
      log = build(:walk_log, duration_minutes: 90)
      expect(log.duration_hours).to eq(1.5)
    end
  end

  describe '#pace_per_km' do
    it 'calculates pace per kilometer' do
      log = build(:walk_log, distance_km: 2.0, duration_minutes: 30)
      expect(log.pace_per_km).to eq(15.0)
    end

    it 'returns 0 if distance is zero' do
      log = build(:walk_log, distance_km: 0, duration_minutes: 30)
      expect(log.pace_per_km).to eq(0)
    end
  end
end
