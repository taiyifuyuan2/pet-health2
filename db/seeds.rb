# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# サンプルユーザーを作成（開発環境のみ）
if Rails.env.development?
  # テストユーザー
  user = User.find_or_create_by!(email: "test@example.com") do |u|
    u.name = "テストユーザー"
    u.password = "password"
    u.password_confirmation = "password"
  end

  # 世帯を作成
  household = Household.find_or_create_by!(name: "テスト世帯") do |h|
    h.name = "テスト世帯"
  end

  # メンバーシップを作成
  Membership.find_or_create_by!(user: user, household: household) do |m|
    m.role = :owner
  end

  # サンプルペット
  pet = Pet.find_or_create_by!(household: household, name: "ポチ") do |p|
    p.species = "dog"
    p.sex = "male"
    p.birthday = Date.current - 2.years
    p.notes = "元気な柴犬です"
  end

  # サンプルイベント（明日のフィラリア）
  Event.find_or_create_by!(household: household, subject: pet, title: "フィラリア予防薬") do |e|
    e.kind = :medication
    e.scheduled_on = Date.current + 1.day
    e.scheduled_time = Time.parse("09:00")
    e.remind_before_minutes = 1440 # 前日
    e.note = "月1回のフィラリア予防薬投与"
  end

  # サンプルイベント（来週のワクチン）
  Event.find_or_create_by!(household: household, subject: pet, title: "混合ワクチン") do |e|
    e.kind = :vaccine
    e.scheduled_on = Date.current + 7.days
    e.scheduled_time = Time.parse("14:00")
    e.remind_before_minutes = 1440 # 前日
    e.note = "年1回の混合ワクチン接種"
  end

  puts "サンプルデータを作成しました:"
  puts "- ユーザー: #{user.email}"
  puts "- 世帯: #{household.name}"
  puts "- ペット: #{pet.name}"
  puts "- イベント: #{Event.count}件"
end
