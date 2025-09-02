require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { should belong_to(:household) }
    it { should belong_to(:subject) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:scheduled_at) }
    it { should validate_presence_of(:event_type) }
  end

  describe 'enums' do
    it { should define_enum_for(:event_type).with_values(vaccine: 0, medication: 1, checkup: 2, other: 3, birthday: 4).backed_by_column_of_type(:string) }
    it { should define_enum_for(:status).with_values(pending: 0, completed: 1, skipped: 2).backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let!(:household) { create(:household) }
    let!(:pet) { create(:pet, household: household) }
    let!(:pending_event) { create(:event, household: household, subject: pet, status: 'pending') }
    let!(:completed_event) { create(:event, household: household, subject: pet, status: 'completed') }

    describe '.pending' do
      it 'returns only pending events' do
        expect(Event.pending).to include(pending_event)
        expect(Event.pending).not_to include(completed_event)
      end
    end

    describe '.completed' do
      it 'returns only completed events' do
        expect(Event.completed).to include(completed_event)
        expect(Event.completed).not_to include(pending_event)
      end
    end
  end


end
