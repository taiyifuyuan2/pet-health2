# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WeightRecords', type: :request do
  let(:user) { create(:user) }
  let(:household) { create(:household) }
  let(:pet) { create(:pet, household: household) }

  before do
    sign_in user
    create(:membership, user: user, household: household)
  end

  describe 'GET /pets/:pet_id/weight_records' do
    it 'returns http success' do
      get pet_weight_records_path(pet)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /pets/:pet_id/weight_records/new' do
    it 'returns http success' do
      get new_pet_weight_record_path(pet)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /pets/:pet_id/weight_records' do
    it 'creates a new weight record' do
      weight_record_params = {
        weight_record: {
          date: Date.current,
          weight_kg: 25.5,
          note: 'テスト体重記録'
        }
      }

      expect do
        post pet_weight_records_path(pet), params: weight_record_params
      end.to change(WeightRecord, :count).by(1)

      expect(response).to redirect_to(pet_weight_records_path(pet))
    end
  end

  describe 'GET /pets/:pet_id/weight_records/:id/edit' do
    let(:weight_record) { create(:weight_record, pet: pet) }

    it 'returns http success' do
      get edit_pet_weight_record_path(pet, weight_record)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /pets/:pet_id/weight_records/:id' do
    let(:weight_record) { create(:weight_record, pet: pet) }

    it 'updates the weight record' do
      patch pet_weight_record_path(pet, weight_record), params: {
        weight_record: { weight_kg: 26.0 }
      }

      expect(response).to redirect_to(pet_weight_records_path(pet))
      expect(weight_record.reload.weight_kg).to eq(26.0)
    end
  end

  describe 'DELETE /pets/:pet_id/weight_records/:id' do
    let!(:weight_record) { create(:weight_record, pet: pet) }

    it 'deletes the weight record' do
      expect do
        delete pet_weight_record_path(pet, weight_record)
      end.to change(WeightRecord, :count).by(-1)

      expect(response).to redirect_to(pet_weight_records_path(pet))
    end
  end
end
