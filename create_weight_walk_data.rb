# frozen_string_literal: true

# 体重記録と散歩ログのテストデータを作成するスクリプト

puts '体重記録と散歩ログのテストデータを作成中...'

# 既存のペットを取得
pets = Pet.all

if pets.empty?
  puts 'ペットが見つかりません。先にペットを作成してください。'
  exit
end

pets.each do |pet|
  puts "#{pet.name}のデータを作成中..."

  # 体重記録を作成（過去30日分）
  (0..29).each do |i|
    date = i.days.ago.to_date
    # 体重に少し変動を加える（±0.5kg以内）
    base_weight = pet.weight_kg || 10.0
    weight_variation = (rand - 0.5) * 1.0
    weight = (base_weight + weight_variation).round(1)

    # 80%の確率で記録を作成
    next unless rand < 0.8

    WeightRecord.find_or_create_by(pet: pet, date: date) do |record|
      record.weight_kg = weight
      record.note = case rand(4)
                    when 0
                      '元気に過ごしています'
                    when 1
                      '食欲良好'
                    when 2
                      '少し疲れ気味'
                    end
    end

    # 散歩ログを作成（過去30日分）
    date = i.days.ago.to_date

    # 60%の確率で散歩記録を作成
    next unless rand < 0.6

    distance = case rand(3)
               when 0
                 rand(1.0..3.0).round(1)  # 1-3km
               when 1
                 rand(3.0..5.0).round(1)  # 3-5km
               else
                 rand(0.5..2.0).round(1)  # 0.5-2km
               end

    duration = (distance * rand(15..25)).round(0) # 15-25分/km

    WalkLog.find_or_create_by(pet: pet, date: date) do |log|
      log.distance_km = distance
      log.duration_minutes = duration
      log.note = case rand(5)
                 when 0
                   '公園でたくさん遊びました'
                 when 1
                   '他の犬と仲良くできました'
                 when 2
                   '雨の日は短めに'
                 when 3
                   '新しい散歩コースを発見'
                 end
    end
  end
end

puts 'データ作成完了！'
puts "作成された体重記録: #{WeightRecord.count}件"
puts "作成された散歩ログ: #{WalkLog.count}件"
