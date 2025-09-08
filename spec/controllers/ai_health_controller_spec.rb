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

  describe 'GET #advice' do
    it 'AI健康アドバイスを取得する' do
      allow_any_instance_of(AiHealthAdvisor).to receive(:generate_personalized_advice).and_return({
        type: 'ai_advice',
        title: 'AI健康アドバイス',
        content: 'テストアドバイス',
        priority: 'high',
        category: 'ai_generated',
        generated_at: Time.current
      })

      get :advice, params: { pet_id: pet.id }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/html')
    end

    it 'JSON形式でもレスポンスを返す' do
      allow_any_instance_of(AiHealthAdvisor).to receive(:generate_personalized_advice).and_return({
        type: 'ai_advice',
        title: 'AI健康アドバイス',
        content: 'テストアドバイス',
        priority: 'high',
        category: 'ai_generated',
        generated_at: Time.current
      })

      get :advice, params: { pet_id: pet.id }, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'POST #question' do
    let(:question) { '最近食欲がないのですが、何か問題がありますか？' }

    it '健康に関する質問に回答する' do
      allow_any_instance_of(AiHealthAdvisor).to receive(:answer_health_question).and_return('AIからの回答です。')

      post :question, params: { pet_id: pet.id, question: question }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/html')
    end

    it '質問が空の場合、エラーを返す' do
      post :question, params: { pet_id: pet.id, question: '' }, format: :json

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to eq('質問を入力してください')
    end

    it 'JSON形式でもレスポンスを返す' do
      allow_any_instance_of(AiHealthAdvisor).to receive(:answer_health_question).and_return('AIからの回答です。')

      post :question, params: { pet_id: pet.id, question: question }, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'GET #analysis' do
    it 'ペットの健康状態を分析する' do
      allow_any_instance_of(AiHealthAdvisor).to receive(:analyze_health_condition).and_return({
        type: 'ai_analysis',
        title: 'AI健康分析',
        content: 'テスト分析結果',
        priority: 'high',
        category: 'ai_analysis',
        generated_at: Time.current
      })

      get :analysis, params: { pet_id: pet.id }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/html')
    end

    it 'JSON形式でもレスポンスを返す' do
      allow_any_instance_of(AiHealthAdvisor).to receive(:analyze_health_condition).and_return({
        type: 'ai_analysis',
        title: 'AI健康分析',
        content: 'テスト分析結果',
        priority: 'high',
        category: 'ai_analysis',
        generated_at: Time.current
      })

      get :analysis, params: { pet_id: pet.id }, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'authentication' do
    before { sign_out user }

    it '未認証ユーザーはアクセスできない' do
      get :advice, params: { pet_id: pet.id }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
