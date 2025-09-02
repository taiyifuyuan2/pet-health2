require 'rails_helper'

RSpec.describe Vaccination, type: :model do
  describe 'associations' do
    it { should belong_to(:pet) }
    it { should belong_to(:vaccine) }
  end

  describe 'validations' do
    it { should validate_presence_of(:due_on) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending completed missed]) }
  end

  describe 'scopes' do
    let!(:pet) { create(:pet) }
    let!(:vaccine) { create(:vaccine) }
    let!(:pending_vaccination) { create(:vaccination, pet: pet, vaccine: vaccine, status: 'pending') }
    let!(:completed_vaccination) { create(:vaccination, pet: pet, vaccine: vaccine, status: 'completed') }
    let!(:today_vaccination) { create(:vaccination, pet: pet, vaccine: vaccine, due_on: Date.current) }
    let!(:future_vaccination) { create(:vaccination, pet: pet, vaccine: vaccine, due_on: 1.week.from_now) }

    describe '.pending' do
      it 'returns only pending vaccinations' do
        expect(Vaccination.pending).to include(pending_vaccination)
        expect(Vaccination.pending).not_to include(completed_vaccination)
      end
    end

    describe '.completed' do
      it 'returns only completed vaccinations' do
        expect(Vaccination.completed).to include(completed_vaccination)
        expect(Vaccination.completed).not_to include(pending_vaccination)
      end
    end

    describe '.due_today' do
      it 'returns vaccinations due today' do
        expect(Vaccination.due_today).to include(today_vaccination)
        expect(Vaccination.due_today).not_to include(future_vaccination)
      end
    end

    describe '.due_soon' do
      it 'returns vaccinations due within a week' do
        expect(Vaccination.due_soon).to include(today_vaccination)
        expect(Vaccination.due_soon).to include(future_vaccination)
      end
    end
  end

  describe '#complete!' do
    let(:vaccination) { create(:vaccination, status: 'pending') }

    it 'marks vaccination as completed' do
      expect { vaccination.complete! }.to change { vaccination.status }.from('pending').to('completed')
    end

    it 'sets completed_at timestamp' do
      expect { vaccination.complete! }.to change { vaccination.completed_at }.from(nil)
    end
  end

  describe '#overdue?' do
    let(:vaccination) { create(:vaccination, status: 'pending', due_on: 1.day.ago) }

    it 'returns true for overdue pending vaccinations' do
      expect(vaccination.overdue?).to be true
    end

    it 'returns false for completed vaccinations' do
      vaccination.update!(status: 'completed')
      expect(vaccination.overdue?).to be false
    end
  end
end
