# frozen_string_literal: true

class AiHealthAdvisor
  def initialize(pet)
    @pet = pet
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.openai_api_key)
  end

  # AIによる個別化された健康アドバイスを生成
  def generate_personalized_advice
    prompt = build_prompt
    response = call_openai_api(prompt)
    parse_response(response)
  rescue StandardError => e
    Rails.logger.error "AI Health Advisor Error: #{e.message}"
    fallback_advice
  end

  # ペットの症状や行動に関する質問にAIが回答
  def answer_health_question(question)
    prompt = build_question_prompt(question)
    response = call_openai_api(prompt)
    parse_question_response(response)
  rescue StandardError => e
    Rails.logger.error "AI Health Question Error: #{e.message}"
    "申し訳ございません。現在AIサービスに接続できません。獣医師にご相談ください。"
  end

  # ペットの健康状態を分析してアドバイスを生成
  def analyze_health_condition
    prompt = build_analysis_prompt
    response = call_openai_api(prompt)
    parse_analysis_response(response)
  rescue StandardError => e
    Rails.logger.error "AI Health Analysis Error: #{e.message}"
    fallback_analysis
  end

  private

  def build_prompt
    pet_info = {
      name: @pet.name,
      species: @pet.species,
      breed: @pet.breed&.name || "不明",
      age_months: @pet.age_in_months,
      weight: @pet.weight_kg,
      sex: @pet.sex || "不明"
    }

    <<~PROMPT
      あなたは経験豊富な獣医師です。以下のペットの情報を基に、個別化された健康アドバイスを提供してください。

      ペット情報:
      - 名前: #{pet_info[:name]}
      - 種類: #{pet_info[:species]}
      - 犬種: #{pet_info[:breed]}
      - 年齢: #{pet_info[:age_months]}ヶ月
      - 体重: #{pet_info[:weight]}kg
      - 性別: #{pet_info[:sex]}

      現在の季節: #{current_season}

      以下の形式で回答してください：
      1. 今日の重要な注意点（高優先度）
      2. 今週のケアポイント（中優先度）
      3. 今月の健康管理（低優先度）
      4. 犬種固有の注意点
      5. 年齢に応じたケア

      各項目は具体的で実践的なアドバイスを含めてください。
      日本語で回答し、飼い主が理解しやすい表現を使用してください。
    PROMPT
  end

  def build_question_prompt(question)
    pet_info = {
      name: @pet.name,
      species: @pet.species,
      breed: @pet.breed&.name || "不明",
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

  def build_analysis_prompt
    pet_info = {
      name: @pet.name,
      species: @pet.species,
      breed: @pet.breed&.name || "不明",
      age_months: @pet.age_in_months,
      weight: @pet.weight_kg,
      sex: @pet.sex || "不明"
    }

    # 最近の体重記録を取得
    recent_weights = @pet.weight_records.order(date: :desc).limit(5).pluck(:weight_kg)
    weight_trend = calculate_weight_trend(recent_weights)

    # 最近の散歩記録を取得
    recent_walks = @pet.walk_logs.where(created_at: 7.days.ago..).count

    <<~PROMPT
      あなたは経験豊富な獣医師です。以下のペットの健康状態を分析し、総合的なアドバイスを提供してください。

      ペット情報:
      - 名前: #{pet_info[:name]}
      - 種類: #{pet_info[:species]}
      - 犬種: #{pet_info[:breed]}
      - 年齢: #{pet_info[:age_months]}ヶ月
      - 体重: #{pet_info[:weight]}kg
      - 性別: #{pet_info[:sex]}

      健康データ:
      - 体重の傾向: #{weight_trend}
      - 最近7日間の散歩回数: #{recent_walks}回
      - 現在の季節: #{current_season}

      以下の観点から分析してください：
      1. 体重管理の状況
      2. 運動量の適切性
      3. 年齢に応じた健康状態
      4. 季節に応じた注意点
      5. 犬種固有のリスク要因

      各項目について具体的なアドバイスと改善提案を含めてください。
      日本語で回答し、飼い主が実践しやすい内容にしてください。
    PROMPT
  end

  def call_openai_api(prompt)
    @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: "あなたは経験豊富な獣医師です。ペットの健康管理について専門的で実践的なアドバイスを提供してください。"
          },
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 1000,
        temperature: 0.7
      }
    )
  end

  def parse_response(response)
    content = response.dig("choices", 0, "message", "content")
    return fallback_advice unless content

    {
      type: 'ai_advice',
      title: 'AI健康アドバイス',
      content: content,
      priority: 'high',
      category: 'ai_generated',
      generated_at: Time.current
    }
  end

  def parse_question_response(response)
    content = response.dig("choices", 0, "message", "content")
    return "申し訳ございません。回答を生成できませんでした。" unless content

    content
  end

  def parse_analysis_response(response)
    content = response.dig("choices", 0, "message", "content")
    return fallback_analysis unless content

    {
      type: 'ai_analysis',
      title: 'AI健康分析',
      content: content,
      priority: 'high',
      category: 'ai_analysis',
      generated_at: Time.current
    }
  end

  def current_season
    month = Date.current.month
    case month
    when 3..5 then "春"
    when 6..8 then "夏"
    when 9..11 then "秋"
    else "冬"
    end
  end

  def calculate_weight_trend(weights)
    return "データ不足" if weights.length < 2

    if weights.length >= 2
      recent = weights.first
      previous = weights[1]
      if recent > previous
        "増加傾向"
      elsif recent < previous
        "減少傾向"
      else
        "安定"
      end
    else
      "データ不足"
    end
  end

  def fallback_advice
    {
      type: 'ai_advice',
      title: 'AI健康アドバイス',
      content: "現在AIサービスに接続できません。従来の健康アドバイスをご確認ください。",
      priority: 'medium',
      category: 'ai_generated',
      generated_at: Time.current
    }
  end

  def fallback_analysis
    {
      type: 'ai_analysis',
      title: 'AI健康分析',
      content: "現在AIサービスに接続できません。獣医師にご相談ください。",
      priority: 'medium',
      category: 'ai_analysis',
      generated_at: Time.current
    }
  end
end
