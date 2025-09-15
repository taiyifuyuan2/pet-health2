# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WalkLogs', type: :request do
  let(:user) { create(:user) }
  let(:household) { create(:household) }
  let(:pet) { create(:pet, household: household) }

  before do
    sign_in user
    create(:membership, user: user, household: household)
  end

  describe 'GET /pets/:pet_id/walk_logs' do
    it 'returns http success' do
      get pet_walk_logs_path(pet)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /pets/:pet_id/walk_logs/new' do
    it 'returns http success' do
      get new_pet_walk_log_path(pet)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /pets/:pet_id/walk_logs' do
    it 'creates a new walk log' do
      walk_log_params = {
        walk_log: {
          date: Date.current,
          distance_km: 2.5,
          duration_minutes: 30,
          note: 'テスト散歩'
        }
      }

      expect do
        post pet_walk_logs_path(pet), params: walk_log_params
      end.to change(WalkLog, :count).by(1)

      expect(response).to redirect_to(pet_walk_logs_path(pet))
    end
  end

  describe 'GET /pets/:pet_id/walk_logs/:id/edit' do
    let(:walk_log) { create(:walk_log, pet: pet) }

    it 'returns http success' do
      get edit_pet_walk_log_path(pet, walk_log)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /pets/:pet_id/walk_logs/:id' do
    let(:walk_log) { create(:walk_log, pet: pet) }

    it 'updates the walk log' do
      patch pet_walk_log_path(pet, walk_log), params: {
        walk_log: { distance_km: 3.0 }
      }

      expect(response).to redirect_to(pet_walk_logs_path(pet))
      expect(walk_log.reload.distance_km).to eq(3.0)
    end
  end

  describe 'DELETE /pets/:pet_id/walk_logs/:id' do
    let!(:walk_log) { create(:walk_log, pet: pet) }

    it 'deletes the walk log' do
      expect do
        delete pet_walk_log_path(pet, walk_log)
      end.to change(WalkLog, :count).by(-1)

      expect(response).to redirect_to(pet_walk_logs_path(pet))
    end
  end
end
