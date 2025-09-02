class HealthAdvisor
  def initialize(pet)
    @pet = pet
  end
  
  # ペットの健康アドバイスを取得
  def get_health_advice
    advice = []
    
    # 犬種固有のアドバイス
    advice.concat(breed_specific_advice)
    
    # 年齢に基づくアドバイス
    advice.concat(age_based_advice)
    
    # 体重に基づくアドバイス
    advice.concat(weight_based_advice)
    
    # 季節に基づくアドバイス
    advice.concat(seasonal_advice)
    
    advice.uniq
  end
  
  # 今日の重要なアドバイスを取得
  def get_todays_advice
    get_health_advice.select { |advice| advice[:priority] == 'high' }
  end
  
  # 今週のアドバイスを取得
  def get_weekly_advice
    get_health_advice.select { |advice| advice[:priority] == 'medium' }
  end
  
  private
  
  def breed_specific_advice
    return [] unless @pet.breed.present?
    
    advice = []
    
    # ダックスフンドの腰・関節トラブル注意
    if @pet.breed.name.downcase.include?('ダックスフンド') && @pet.age_in_months >= 6
      advice << {
        type: 'health_risk',
        title: '腰・関節トラブル注意',
        message: 'ダックスフンドは6か月以降、腰や関節のトラブルに注意が必要です。階段の上り下りを控え、適度な運動を心がけましょう。',
        priority: 'high',
        category: 'breed_specific'
      }
    end
    
    # 大型犬の股関節形成不全注意
    if @pet.breed.name.downcase.include?('ゴールデンレトリバー') && @pet.age_in_months >= 4
      advice << {
        type: 'health_risk',
        title: '股関節形成不全注意',
        message: '大型犬は股関節形成不全になりやすい傾向があります。過度な運動を避け、適切な体重管理を心がけましょう。',
        priority: 'medium',
        category: 'breed_specific'
      }
    end
    
    advice
  end
  
  def age_based_advice
    advice = []
    age_months = @pet.age_in_months
    
    # 子犬期（0-6か月）
    if age_months <= 6
      advice << {
        type: 'care_tip',
        title: '子犬期のケア',
        message: '子犬期は成長が早い時期です。栄養バランスの良い食事と適度な運動を心がけましょう。',
        priority: 'medium',
        category: 'age_based'
      }
    end
    
    # 成犬期（6か月-7歳）
    if age_months > 6 && age_months < 84
      advice << {
        type: 'care_tip',
        title: '成犬期のケア',
        message: '成犬期は健康管理が重要です。定期的な健康チェックと適切な運動を続けましょう。',
        priority: 'low',
        category: 'age_based'
      }
    end
    
    # シニア期（7歳以上）
    if age_months >= 84
      advice << {
        type: 'health_risk',
        title: 'シニア期のケア',
        message: 'シニア期に入りました。定期的な健康チェックと、年齢に応じた食事管理が重要です。',
        priority: 'high',
        category: 'age_based'
      }
    end
    
    advice
  end
  
  def weight_based_advice
    return [] unless @pet.weight_kg.present?
    
    advice = []
    
    # 肥満注意
    if @pet.weight_kg > 30
      advice << {
        type: 'health_risk',
        title: '体重管理注意',
        message: '体重が重めです。適切な食事管理と運動で体重をコントロールしましょう。',
        priority: 'medium',
        category: 'weight_based'
      }
    end
    
    # 痩せすぎ注意
    if @pet.weight_kg < 5
      advice << {
        type: 'health_risk',
        title: '栄養不足注意',
        message: '体重が軽めです。栄養バランスの良い食事を心がけましょう。',
        priority: 'medium',
        category: 'weight_based'
      }
    end
    
    advice
  end
  
  def seasonal_advice
    advice = []
    current_month = Date.current.month
    
    # 春（3-5月）
    if current_month >= 3 && current_month <= 5
      advice << {
        type: 'seasonal_tip',
        title: '春のケア',
        message: '春はノミ・ダニの活動が活発になります。予防薬の投与を忘れずに。',
        priority: 'medium',
        category: 'seasonal'
      }
    end
    
    # 夏（6-8月）
    if current_month >= 6 && current_month <= 8
      advice << {
        type: 'health_risk',
        title: '熱中症注意',
        message: '夏は熱中症に注意が必要です。十分な水分補給と涼しい環境を心がけましょう。',
        priority: 'high',
        category: 'seasonal'
      }
    end
    
    # 秋（9-11月）
    if current_month >= 9 && current_month <= 11
      advice << {
        type: 'seasonal_tip',
        title: '秋のケア',
        message: '秋は換毛期です。ブラッシングを頻繁に行い、毛玉を防ぎましょう。',
        priority: 'low',
        category: 'seasonal'
      }
    end
    
    # 冬（12-2月）
    if current_month == 12 || current_month <= 2
      advice << {
        type: 'seasonal_tip',
        title: '冬のケア',
        message: '冬は乾燥しやすい季節です。皮膚のケアと適切な湿度管理を心がけましょう。',
        priority: 'low',
        category: 'seasonal'
      }
    end
    
    advice
  end
end
