# frozen_string_literal: true

class AiHealthAdvisor
  def initialize(pet)
    @pet = pet
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  # ペットの症状や行動に関する質問にAIが回答
  def answer_health_question(question)
    prompt = build_question_prompt(question)
    response = call_openai_api(prompt)
    parse_question_response(response)
  rescue StandardError => e
    Rails.logger.error "AI Health Question Error: #{e.message}"
    '申し訳ございません。現在AIサービスに接続できません。獣医師にご相談ください。'
  end

  private

  def build_question_prompt(question)
    pet_info = {
      name: @pet.name,
      species: @pet.species,
      breed: @pet.breed&.name || '不明',
      age_months: @pet.age_in_months,
      weight: @pet.weight_kg
    }

    <<~PROMPT
      あなたは経験豊富な獣医師です。以下のペットについて質問にお答えください。

      ペット情報:
      - 名前: #{pet_info[:name]}
      - 種類: #{pet_info[:species]}
      - 犬種: #{pet_info[:breed]}
      - 年齢: #{pet_info[:age_months]}ヶ月
      - 体重: #{pet_info[:weight]}kg

      質問: #{question}

      回答の際は以下の点に注意してください：
      1. 一般的なアドバイスを提供するが、緊急時は獣医師の受診を推奨する
      2. 具体的で実践的なアドバイスを心がける
      3. 日本語で分かりやすく回答する
      4. 不安な症状がある場合は必ず獣医師に相談するよう促す
    PROMPT
  end

  def call_openai_api(prompt)
    @client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: 'あなたは経験豊富な獣医師です。ペットの健康管理について専門的で実践的なアドバイスを提供してください。'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        max_tokens: 1000,
        temperature: 0.7
      }
    )
  end

  def parse_question_response(response)
    content = response.dig('choices', 0, 'message', 'content')
    return '申し訳ございません。回答を生成できませんでした。' unless content

    content
  end

  def current_season
    month = Date.current.month
    case month
    when 3..5 then '春'
    when 6..8 then '夏'
    when 9..11 then '秋'
    else '冬'
    end
  end

  def calculate_weight_trend(weights)
    return 'データ不足' if weights.length < 2

    if weights.length >= 2
      recent = weights.first
      previous = weights[1]
      if recent > previous
        '増加傾向'
      elsif recent < previous
        '減少傾向'
      else
        '安定'
      end
    else
      'データ不足'
    end
  end
end
