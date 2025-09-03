require 'rails_helper'

RSpec.describe WalkLogsController, type: :controller do
  let(:user) { create(:user) }
  let(:household) { create(:household) }
  let(:pet) { create(:pet, household: household) }
  let(:walk_log) { create(:walk_log, pet: pet) }

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

    it 'assigns @walk_logs' do
      get :index, params: { pet_id: pet.id }
      expect(assigns(:walk_logs)).to eq(pet.walk_logs.recent)
    end

    it 'assigns summary statistics' do
      get :index, params: { pet_id: pet.id }
      expect(assigns(:weekly_total_distance)).to be_present
      expect(assigns(:weekly_total_duration)).to be_present
      expect(assigns(:monthly_total_distance)).to be_present
      expect(assigns(:monthly_total_duration)).to be_present
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new, params: { pet_id: pet.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @walk_log with current date' do
      get :new, params: { pet_id: pet.id }
      expect(assigns(:walk_log).date).to eq(Date.current)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new walk log' do
        expect {
          post :create, params: { 
            pet_id: pet.id, 
            walk_log: { 
              date: Date.current, 
              distance_km: 2.5, 
              duration_minutes: 30,
              note: 'Test walk' 
            } 
          }
        }.to change(WalkLog, :count).by(1)
      end

      it 'redirects to walk logs index' do
        post :create, params: { 
          pet_id: pet.id, 
          walk_log: { 
            date: Date.current, 
            distance_km: 2.5, 
            duration_minutes: 30,
            note: 'Test walk' 
          } 
        }
        expect(response).to redirect_to(pet_walk_logs_path(pet))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new walk log' do
        expect {
          post :create, params: { 
            pet_id: pet.id, 
            walk_log: { 
              date: Date.current, 
              distance_km: nil, 
              duration_minutes: 30 
            } 
          }
        }.not_to change(WalkLog, :count)
      end

      it 'renders new template' do
        post :create, params: { 
          pet_id: pet.id, 
          walk_log: { 
            date: Date.current, 
            distance_km: nil, 
            duration_minutes: 30 
          } 
        }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { pet_id: pet.id, id: walk_log.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @walk_log' do
      get :edit, params: { pet_id: pet.id, id: walk_log.id }
      expect(assigns(:walk_log)).to eq(walk_log)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      it 'updates the walk log' do
        patch :update, params: { 
          pet_id: pet.id, 
          id: walk_log.id, 
          walk_log: { distance_km: 3.0 } 
        }
        walk_log.reload
        expect(walk_log.distance_km).to eq(3.0)
      end

      it 'redirects to walk logs index' do
        patch :update, params: { 
          pet_id: pet.id, 
          id: walk_log.id, 
          walk_log: { distance_km: 3.0 } 
        }
        expect(response).to redirect_to(pet_walk_logs_path(pet))
      end
    end

    context 'with invalid parameters' do
      it 'does not update the walk log' do
        original_distance = walk_log.distance_km
        patch :update, params: { 
          pet_id: pet.id, 
          id: walk_log.id, 
          walk_log: { distance_km: nil } 
        }
        walk_log.reload
        expect(walk_log.distance_km).to eq(original_distance)
      end

      it 'renders edit template' do
        patch :update, params: { 
          pet_id: pet.id, 
          id: walk_log.id, 
          walk_log: { distance_km: nil } 
        }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the walk log' do
      walk_log # create the record
      expect {
        delete :destroy, params: { pet_id: pet.id, id: walk_log.id }
      }.to change(WalkLog, :count).by(-1)
    end

    it 'redirects to walk logs index' do
      delete :destroy, params: { pet_id: pet.id, id: walk_log.id }
      expect(response).to redirect_to(pet_walk_logs_path(pet))
    end
  end
end
