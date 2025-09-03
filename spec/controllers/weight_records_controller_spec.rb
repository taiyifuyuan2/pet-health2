# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeightRecordsController, type: :controller do
  let(:user) { create(:user) }
  let(:household) { create(:household) }
  let(:pet) { create(:pet, household: household) }
  let(:weight_record) { create(:weight_record, pet: pet) }

  before do
    sign_in user
    create(:membership, user: user, household: household)
    allow(controller).to receive(:current_household).and_return(household)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { pet_id: pet.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @weight_records' do
      get :index, params: { pet_id: pet.id }
      expect(assigns(:weight_records)).to eq(pet.weight_records.recent)
    end

    it 'assigns @chart_data' do
      get :index, params: { pet_id: pet.id }
      expect(assigns(:chart_data)).to be_present
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new, params: { pet_id: pet.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @weight_record with current date' do
      get :new, params: { pet_id: pet.id }
      expect(assigns(:weight_record).date).to eq(Date.current)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new weight record' do
        expect do
          post :create, params: {
            pet_id: pet.id,
            weight_record: {
              date: Date.current,
              weight_kg: 10.5,
              note: 'Test note'
            }
          }
        end.to change(WeightRecord, :count).by(1)
      end

      it 'redirects to weight records index' do
        post :create, params: {
          pet_id: pet.id,
          weight_record: {
            date: Date.current,
            weight_kg: 10.5,
            note: 'Test note'
          }
        }
        expect(response).to redirect_to(pet_weight_records_path(pet))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new weight record' do
        expect do
          post :create, params: {
            pet_id: pet.id,
            weight_record: {
              date: Date.current,
              weight_kg: nil
            }
          }
        end.not_to change(WeightRecord, :count)
      end

      it 'renders new template' do
        post :create, params: {
          pet_id: pet.id,
          weight_record: {
            date: Date.current,
            weight_kg: nil
          }
        }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { pet_id: pet.id, id: weight_record.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @weight_record' do
      get :edit, params: { pet_id: pet.id, id: weight_record.id }
      expect(assigns(:weight_record)).to eq(weight_record)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      it 'updates the weight record' do
        patch :update, params: {
          pet_id: pet.id,
          id: weight_record.id,
          weight_record: { weight_kg: 11.0 }
        }
        weight_record.reload
        expect(weight_record.weight_kg).to eq(11.0)
      end

      it 'redirects to weight records index' do
        patch :update, params: {
          pet_id: pet.id,
          id: weight_record.id,
          weight_record: { weight_kg: 11.0 }
        }
        expect(response).to redirect_to(pet_weight_records_path(pet))
      end
    end

    context 'with invalid parameters' do
      it 'does not update the weight record' do
        original_weight = weight_record.weight_kg
        patch :update, params: {
          pet_id: pet.id,
          id: weight_record.id,
          weight_record: { weight_kg: nil }
        }
        weight_record.reload
        expect(weight_record.weight_kg).to eq(original_weight)
      end

      it 'renders edit template' do
        patch :update, params: {
          pet_id: pet.id,
          id: weight_record.id,
          weight_record: { weight_kg: nil }
        }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the weight record' do
      weight_record # create the record
      expect do
        delete :destroy, params: { pet_id: pet.id, id: weight_record.id }
      end.to change(WeightRecord, :count).by(-1)
    end

    it 'redirects to weight records index' do
      delete :destroy, params: { pet_id: pet.id, id: weight_record.id }
      expect(response).to redirect_to(pet_weight_records_path(pet))
    end
  end
end
