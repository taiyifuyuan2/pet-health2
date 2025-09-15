# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiHealthAdvisor, type: :service do
  let(:pet) { create(:pet) }
  let(:ai_advisor) { described_class.new(pet) }

  before do
    allow(OpenAI::Client).to receive(:new).and_return(double('client'))
  end

  describe '#answer_health_question' do
    let(:question) { '最近食欲がないのですが、何か問題がありますか？' }

    it 'AI健康相談に回答する' do
      mock_response = {
        'choices' => [
          {
            'message' => {
              'content' => 'テスト回答'
            }
          }
        ]
      }

      allow(ai_advisor.instance_variable_get(:@client)).to receive(:chat).and_return(mock_response)

      answer = ai_advisor.answer_health_question(question)

      expect(answer).to eq('テスト回答')
    end

    it 'APIエラーが発生した場合 エラーメッセージを返す' do
      allow(ai_advisor.instance_variable_get(:@client)).to receive(:chat).and_raise(StandardError.new('API Error'))

      answer = ai_advisor.answer_health_question(question)

      expect(answer).to include('申し訳ございません')
    end
  end

  describe 'private methods' do
    describe '#current_season' do
      it '現在の季節を返す' do
        allow(Date).to receive(:current).and_return(Date.new(2024, 6, 15))
        expect(ai_advisor.send(:current_season)).to eq('夏')
      end
    end

    describe '#calculate_weight_trend' do
      it '体重の傾向を計算する（減少傾向）' do
        weights = [9.0, 9.5, 10.0]  # 古い順から新しい順
        trend = ai_advisor.send(:calculate_weight_trend, weights)
        expect(trend).to eq('減少傾向')
      end

      it '体重の傾向を計算する（増加傾向）' do
        weights = [10.0, 9.5, 9.0]  # 古い順から新しい順
        trend = ai_advisor.send(:calculate_weight_trend, weights)
        expect(trend).to eq('増加傾向')
      end

      it 'データが不足している場合は「データ不足」を返す' do
        weights = [10.0]
        trend = ai_advisor.send(:calculate_weight_trend, weights)
        expect(trend).to eq('データ不足')
      end
    end
  end
end
