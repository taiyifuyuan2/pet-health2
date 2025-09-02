require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { create(:user) }
  let(:household) { create(:household) }
  let(:membership) { create(:membership, user: user, household: household) }

  before do
    sign_in user
    allow(controller).to receive(:current_household).and_return(household)
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end

    it 'assigns @household' do
      get :show
      expect(assigns(:household)).to eq(household)
    end

    it 'assigns @today' do
      get :show
      expect(assigns(:today)).to eq(Date.current)
    end

    it 'assigns @this_month' do
      get :show
      today = Date.current
      expected_range = today.beginning_of_month..today.end_of_month
      expect(assigns(:this_month)).to eq(expected_range)
    end

    it 'assigns @upcoming_events' do
      get :show
      expect(assigns(:upcoming_events)).to be_a(ActiveRecord::AssociationRelation)
    end

    it 'assigns @overdue_events' do
      get :show
      expect(assigns(:overdue_events)).to be_a(ActiveRecord::AssociationRelation)
    end

    it 'assigns @recent_completed' do
      get :show
      expect(assigns(:recent_completed)).to be_a(ActiveRecord::AssociationRelation)
    end
  end
end
