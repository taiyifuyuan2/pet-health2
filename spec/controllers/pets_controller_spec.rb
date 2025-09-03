# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PetsController, type: :controller do
  let(:user) { create(:user) }
  let(:household) { create(:household) }
  let(:membership) { create(:membership, user: user, household: household) }
  let(:pet) { create(:pet, household: household) }

  before do
    sign_in user
    allow(controller).to receive(:current_household).and_return(household)
    allow(controller).to receive(:current_user).and_return(user)
    allow(household.pets).to receive(:find).with(pet.id.to_s).and_return(pet)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns @pets' do
      get :index
      expect(assigns(:pets)).to eq([pet])
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: pet.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @pet' do
      get :show, params: { id: pet.id }
      expect(assigns(:pet)).to eq(pet)
    end

    it 'assigns @events' do
      get :show, params: { id: pet.id }
      expect(assigns(:events)).to eq(pet.events.order(:scheduled_at))
    end

    it 'assigns @vaccinations' do
      get :show, params: { id: pet.id }
      expect(assigns(:vaccinations)).to eq(pet.vaccinations.includes(:vaccine).order(:due_on))
    end

    it 'assigns @notifications' do
      get :show, params: { id: pet.id }
      expect(assigns(:notifications)).to eq(pet.notifications.order(:scheduled_for))
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns @pet' do
      get :new
      expect(assigns(:pet)).to be_a_new(Pet)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        name: 'テストペット',
        species: 'dog',
        sex: 'male',
        birthdate: 1.year.ago,
        weight_kg: 10.0
      }
    end

    context 'with valid parameters' do
      it 'creates a new pet' do
        expect do
          post :create, params: { pet: valid_attributes }
        end.to change(Pet, :count).by(1)
      end

      it 'redirects to the created pet' do
        post :create, params: { pet: valid_attributes }
        expect(response).to redirect_to(Pet.last)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not create a new pet' do
        expect do
          post :create, params: { pet: invalid_attributes }
        end.not_to change(Pet, :count)
      end

      it 'renders the new template' do
        post :create, params: { pet: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: pet.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @pet' do
      get :edit, params: { id: pet.id }
      expect(assigns(:pet)).to eq(pet)
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) { { name: '新しい名前' } }

    context 'with valid parameters' do
      it 'updates the pet' do
        patch :update, params: { id: pet.id, pet: new_attributes }
        pet.reload
        expect(pet.name).to eq('新しい名前')
      end

      it 'redirects to the pet' do
        patch :update, params: { id: pet.id, pet: new_attributes }
        expect(response).to redirect_to(pet)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not update the pet' do
        original_name = pet.name
        patch :update, params: { id: pet.id, pet: invalid_attributes }
        pet.reload
        expect(pet.name).to eq(original_name)
      end

      it 'renders the edit template' do
        patch :update, params: { id: pet.id, pet: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the pet' do
      expect do
        delete :destroy, params: { id: pet.id }
      end.to change(Pet, :count).by(-1)
    end

    it 'redirects to pets index' do
      delete :destroy, params: { id: pet.id }
      expect(response).to redirect_to(pets_path)
    end
  end
end
