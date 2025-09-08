# frozen_string_literal: true

# 本番環境用データ作成スクリプト
puts '本番環境用データを作成中...'

# 既存のユーザーを確認
if User.count == 0
  puts 'ユーザーを作成中...'
  user = User.create!(
    email: 'demo@example.com',
    password: 'password123',
    password_confirmation: 'password123',
    name: 'デモユーザー'
  )
  puts "ユーザー作成完了: #{user.email}"
else
  user = User.first
  puts "既存ユーザーを使用: #{user.email}"
end

# 既存のペットを確認
if Pet.count == 0
  puts 'ペットを作成中...'
  breed = Breed.first || Breed.create!(name: 'ダックスフンド', risk_tags: {})
  pet = Pet.create!(
    user: user,
    name: 'ラム',
    breed: breed,
    birth_date: 2.years.ago.to_date,
    weight_kg: 7.6,
    gender: 'male',
    neutered: false
  )
  puts "ペット作成完了: #{pet.name}"
else
  pet = Pet.first
  puts "既存ペットを使用: #{pet.name}"
end

# 体重記録を作成
puts '体重記録を作成中...'
weight_count = 0
(0..29).each do |i|
  date = i.days.ago.to_date
  base_weight = pet.weight_kg
  weight_variation = (rand - 0.5) * 1.0
  weight = (base_weight + weight_variation).round(1)
  
  if rand < 0.8  # 80%の確率で記録を作成
    WeightRecord.find_or_create_by(pet: pet, date: date) do |record|
      record.weight_kg = weight
      record.note = ['元気に過ごしています', '食欲良好', '少し疲れ気味'].sample
    end
    weight_count += 1
  end
end

# 散歩ログを作成
puts '散歩ログを作成中...'
walk_count = 0
(0..29).each do |i|
  date = i.days.ago.to_date
  
  if rand < 0.6  # 60%の確率で散歩記録を作成
    distance = case rand(3)
               when 0 then rand(1.0..3.0).round(1)  # 1-3km
               when 1 then rand(3.0..5.0).round(1)  # 3-5km
               else rand(0.5..2.0).round(1)         # 0.5-2km
               end
    
    duration = (distance * rand(15..25)).round(0)
    
    WalkLog.find_or_create_by(pet: pet, date: date) do |log|
      log.distance_km = distance
      log.duration_minutes = duration
      log.note = ['公園でたくさん遊びました', '他の犬と仲良くできました', '雨の日は短めに', '新しい散歩コースを発見'].sample
    end
    walk_count += 1
  end
end

puts 'データ作成完了！'
puts "- ユーザー: #{User.count}件"
puts "- ペット: #{Pet.count}件"
puts "- 体重記録: #{WeightRecord.count}件"
puts "- 散歩ログ: #{WalkLog.count}件"
puts "- 今回作成した体重記録: #{weight_count}件"
puts "- 今回作成した散歩ログ: #{walk_count}件"
