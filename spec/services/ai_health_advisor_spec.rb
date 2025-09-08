# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiHealthAdvisor, type: :service do
  let(:household) { create(:household) }
  let(:breed) { create(:breed, name: 'ゴールデンレトリバー') }
  let(:pet) { create(:pet, household: household, breed: breed, weight_kg: 25.0, birthdate: 2.years.ago) }
  let(:ai_advisor) { described_class.new(pet) }

  before do
    # OpenAI APIのモック設定
    allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return({
      'choices' => [
        {
          'message' => {
            'content' => 'AI生成された健康アドバイスです。'
          }
        }
      ]
    })
  end

  describe '#generate_personalized_advice' do
    it 'AIによる個別化されたアドバイスを生成する' do
      advice = ai_advisor.generate_personalized_advice

      expect(advice).to be_a(Hash)
      expect(advice[:type]).to eq('ai_advice')
      expect(advice[:title]).to eq('AI健康アドバイス')
      expect(advice[:content]).to include('AI生成された健康アドバイスです。')
      expect(advice[:priority]).to eq('high')
      expect(advice[:category]).to eq('ai_generated')
      expect(advice[:generated_at]).to be_present
    end

    context 'APIエラーが発生した場合' do
      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_raise(StandardError.new('API Error'))
      end

      it 'フォールバックアドバイスを返す' do
        advice = ai_advisor.generate_personalized_advice

        expect(advice[:type]).to eq('ai_advice')
        expect(advice[:content]).to include('現在AIサービスに接続できません')
      end
    end
  end

  describe '#answer_health_question' do
    let(:question) { '最近食欲がないのですが、何か問題がありますか？' }

    it '健康に関する質問に回答する' do
      answer = ai_advisor.answer_health_question(question)

      expect(answer).to be_a(String)
      expect(answer).to include('AI生成された健康アドバイスです。')
    end

    context 'APIエラーが発生した場合' do
      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_raise(StandardError.new('API Error'))
      end

      it 'エラーメッセージを返す' do
        answer = ai_advisor.answer_health_question(question)

        expect(answer).to include('申し訳ございません。現在AIサービスに接続できません')
      end
    end
  end

  describe '#analyze_health_condition' do
    before do
      # 体重記録と散歩記録のモック
      weight_records_relation = double('weight_records_relation')
      allow(weight_records_relation).to receive(:order).with(date: :desc).and_return(weight_records_relation)
      allow(weight_records_relation).to receive(:limit).with(5).and_return(weight_records_relation)
      allow(weight_records_relation).to receive(:pluck).with(:weight_kg).and_return([25.0, 24.5, 24.0])
      allow(pet).to receive(:weight_records).and_return(weight_records_relation)

      walk_logs_relation = double('walk_logs_relation')
      allow(walk_logs_relation).to receive(:where).and_return(walk_logs_relation)
      allow(walk_logs_relation).to receive(:count).and_return(5)
      allow(pet).to receive(:walk_logs).and_return(walk_logs_relation)
    end

    it 'ペットの健康状態を分析する' do
      allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return({
        'choices' => [
          {
            'message' => {
              'content' => 'AI生成された健康分析結果です。'
            }
          }
        ]
      })

      analysis = ai_advisor.analyze_health_condition

      expect(analysis).to be_a(Hash)
      expect(analysis[:type]).to eq('ai_analysis')
      expect(analysis[:title]).to eq('AI健康分析')
      expect(analysis[:content]).to include('AI生成された健康分析結果です。')
      expect(analysis[:priority]).to eq('high')
      expect(analysis[:category]).to eq('ai_analysis')
      expect(analysis[:generated_at]).to be_present
    end

    context 'APIエラーが発生した場合' do
      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_raise(StandardError.new('API Error'))
      end

      it 'フォールバック分析を返す' do
        analysis = ai_advisor.analyze_health_condition

        expect(analysis[:type]).to eq('ai_analysis')
        expect(analysis[:content]).to include('現在AIサービスに接続できません')
      end
    end
  end

  describe 'private methods' do
    describe '#current_season' do
      it '現在の季節を正しく判定する' do
        allow(Date).to receive(:current).and_return(Date.new(2024, 3, 15))
        expect(ai_advisor.send(:current_season)).to eq('春')

        allow(Date).to receive(:current).and_return(Date.new(2024, 7, 15))
        expect(ai_advisor.send(:current_season)).to eq('夏')

        allow(Date).to receive(:current).and_return(Date.new(2024, 10, 15))
        expect(ai_advisor.send(:current_season)).to eq('秋')

        allow(Date).to receive(:current).and_return(Date.new(2024, 1, 15))
        expect(ai_advisor.send(:current_season)).to eq('冬')
      end
    end

    describe '#calculate_weight_trend' do
      it '体重の傾向を正しく計算する' do
        # 配列の最初の要素が最新の体重（recent）、2番目が前回の体重（previous）
        weights = [25.0, 24.5, 24.0]  # 最新が重い（増加傾向）
        trend = ai_advisor.send(:calculate_weight_trend, weights)
        expect(trend).to eq('増加傾向')

        weights = [24.0, 24.5, 25.0]  # 最新が軽い（減少傾向）
        trend = ai_advisor.send(:calculate_weight_trend, weights)
        expect(trend).to eq('減少傾向')

        weights = [25.0, 25.0]
        trend = ai_advisor.send(:calculate_weight_trend, weights)
        expect(trend).to eq('安定')

        weights = [25.0]
        trend = ai_advisor.send(:calculate_weight_trend, weights)
        expect(trend).to eq('データ不足')
      end
    end
  end
end
