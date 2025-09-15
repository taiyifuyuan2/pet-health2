# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiHealthController, type: :controller do
  let(:user) { create(:user) }
  let(:household) { create(:household) }
  let(:pet) { create(:pet, household: household) }

  before do
    sign_in user
    allow(controller).to receive(:current_household).and_return(household)
  end

  describe 'POST #question' do
    let(:question) { '最近食欲がないのですが、何か問題がありますか？' }

    it 'AI健康相談に回答する' do
      allow_any_instance_of(AiHealthAdvisor).to receive(:answer_health_question).and_return('テスト回答')

      post :question, params: { pet_id: pet.id, question: question }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/html')
    end

    it 'JSON形式でもレスポンスを返す' do
      allow_any_instance_of(AiHealthAdvisor).to receive(:answer_health_question).and_return('テスト回答')

      post :question, params: { pet_id: pet.id, question: question }, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
    end

    it '空の質問の場合はエラーを返す' do
      post :question, params: { pet_id: pet.id, question: '' }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'authentication' do
    it '未認証ユーザーはアクセスできない' do
      sign_out user

      post :question, params: { pet_id: pet.id, question: 'テスト質問' }

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
