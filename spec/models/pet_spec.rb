require 'rails_helper'

RSpec.describe Pet, type: :model do
  describe 'associations' do
    it { should belong_to(:household) }
    it { should belong_to(:breed).optional }
    it { should have_many(:events).dependent(:destroy) }
    it { should have_many(:vaccinations).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:species) }
    it { should validate_numericality_of(:weight_kg).is_greater_than(0).allow_nil }
  end

  describe 'methods' do
    let(:pet) { create(:pet, birthdate: 2.years.ago) }

    describe '#age_in_months' do
      it 'returns age in months' do
        expect(pet.age_in_months).to be_between(20, 28)
      end
    end

    describe '#age_in_weeks' do
      it 'returns age in weeks' do
        expect(pet.age_in_weeks).to be_between(80, 120)
      end
    end

    describe '#profile_image_url' do
      context 'when profile_image is present' do
        let(:pet_with_image) { create(:pet, profile_image: 'https://example.com/image.jpg') }
        
        it 'returns the profile image URL' do
          expect(pet_with_image.profile_image_url).to eq('https://example.com/image.jpg')
        end
      end

      context 'when profile_image is not present' do
        it 'returns a generated avatar URL' do
          expect(pet.profile_image_url).to include('ui-avatars.com')
          expect(pet.profile_image_url).to include(pet.name)
        end
      end
    end
  end
end
