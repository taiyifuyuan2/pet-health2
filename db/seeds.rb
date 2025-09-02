# 犬種データを作成
breeds = [
  {
    name: "ダックスフンド",
    risk_tags: {
      "6-120" => ["腰・関節トラブル", "椎間板ヘルニア", "肥満注意"]
    }
  },
  {
    name: "ゴールデンレトリバー",
    risk_tags: {
      "4-120" => ["股関節形成不全", "肘関節形成不全", "肥満注意"],
      "84-120" => ["がん", "心疾患", "関節炎"]
    }
  },
  {
    name: "柴犬",
    risk_tags: {
      "0-120" => ["皮膚疾患", "アレルギー"],
      "60-120" => ["白内障", "緑内障"]
    }
  },
  {
    name: "トイプードル",
    risk_tags: {
      "0-120" => ["膝蓋骨脱臼", "皮膚疾患", "歯周病"]
    }
  }
]

breeds.each do |breed_data|
  Breed.find_or_create_by(name: breed_data[:name]) do |breed|
    breed.risk_tags = breed_data[:risk_tags]
  end
end

# ワクチンデータを作成
vaccines = [
  {
    name: "混合ワクチン（5種）",
    description: "犬ジステンパー、犬パルボウイルス感染症、犬アデノウイルス2型感染症、犬パラインフルエンザ、犬コロナウイルス感染症を予防"
  },
  {
    name: "狂犬病ワクチン",
    description: "狂犬病を予防（法律で義務付けられている）"
  },
  {
    name: "レプトスピラワクチン",
    description: "レプトスピラ症を予防"
  },
  {
    name: "ボルデテラワクチン",
    description: "ケンネルコフ（犬の咳）を予防"
  }
]

vaccines.each do |vaccine_data|
  vaccine = Vaccine.find_or_create_by(name: vaccine_data[:name]) do |v|
    v.description = vaccine_data[:description]
  end
  
  # ワクチンスケジュールルールを作成
  case vaccine.name
  when "混合ワクチン（5種）"
    VaccineScheduleRule.find_or_create_by(vaccine: vaccine) do |rule|
      rule.min_age_weeks = 6
      rule.repeat_every_days = 365
      rule.booster_times = 0
    end
  when "狂犬病ワクチン"
    VaccineScheduleRule.find_or_create_by(vaccine: vaccine) do |rule|
      rule.min_age_weeks = 12
      rule.repeat_every_days = 365
      rule.booster_times = 0
    end
  when "レプトスピラワクチン"
    VaccineScheduleRule.find_or_create_by(vaccine: vaccine) do |rule|
      rule.min_age_weeks = 8
      rule.repeat_every_days = 365
      rule.booster_times = 0
    end
  when "ボルデテラワクチン"
    VaccineScheduleRule.find_or_create_by(vaccine: vaccine) do |rule|
      rule.min_age_weeks = 6
      rule.repeat_every_days = 365
      rule.booster_times = 0
    end
  end
end

# 投薬プランデータを作成
medication_plans = [
  {
    name: "ノミ・ダニ予防薬",
    dosage_mg_per_kg: 0.5,
    interval_days: 30,
    season_from: Date.new(2024, 3, 1),
    season_to: Date.new(2024, 11, 30)
  },
  {
    name: "フィラリア予防薬",
    dosage_mg_per_kg: 0.1,
    interval_days: 30,
    season_from: Date.new(2024, 5, 1),
    season_to: Date.new(2024, 12, 31)
  },
  {
    name: "サプリメント（グルコサミン）",
    dosage_mg_per_kg: 20,
    interval_days: 1,
    season_from: nil,
    season_to: nil
  }
]

medication_plans.each do |plan_data|
  MedicationPlan.find_or_create_by(name: plan_data[:name]) do |plan|
    plan.dosage_mg_per_kg = plan_data[:dosage_mg_per_kg]
    plan.interval_days = plan_data[:interval_days]
    plan.season_from = plan_data[:season_from]
    plan.season_to = plan_data[:season_to]
  end
end

# 健康リスクルールを作成
health_risk_rules = [
  {
    trigger_conditions: {
      "breed_names" => ["ダックスフンド"],
      "age_months" => { "min" => 6 }
    },
    message: "ダックスフンドは6か月以降、腰や関節のトラブルに注意が必要です。階段の上り下りを控え、適度な運動を心がけましょう。",
    priority: 1
  },
  {
    trigger_conditions: {
      "breed_names" => ["ゴールデンレトリバー"],
      "age_months" => { "min" => 4 }
    },
    message: "大型犬は股関節形成不全になりやすい傾向があります。過度な運動を避け、適切な体重管理を心がけましょう。",
    priority: 2
  },
  {
    trigger_conditions: {
      "age_months" => { "min" => 84 }
    },
    message: "シニア期に入りました。定期的な健康チェックと、年齢に応じた食事管理が重要です。",
    priority: 1
  },
  {
    trigger_conditions: {
      "weight_kg" => { "min" => 30 }
    },
    message: "体重が重めです。適切な食事管理と運動で体重をコントロールしましょう。",
    priority: 2
  }
]

health_risk_rules.each do |rule_data|
  HealthRiskRule.find_or_create_by(message: rule_data[:message]) do |rule|
    rule.trigger_conditions = rule_data[:trigger_conditions]
    rule.priority = rule_data[:priority]
  end
end

puts "シードデータの作成が完了しました！"
puts "- 犬種: #{Breed.count}件"
puts "- ワクチン: #{Vaccine.count}件"
puts "- ワクチンスケジュールルール: #{VaccineScheduleRule.count}件"
puts "- 投薬プラン: #{MedicationPlan.count}件"
puts "- 健康リスクルール: #{HealthRiskRule.count}件"