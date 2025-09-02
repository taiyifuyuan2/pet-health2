# ペット健康管理カレンダー

ペットの予防接種・投薬スケジュールを家族と共有して管理するWebアプリケーションです。

## 機能

### 基本機能
- ペット登録（複数頭対応）
- 予定登録（ワクチン/投薬/健診/その他/誕生日）
- メール通知（前日・当日9:00）
- 履歴管理（完了チェック）
- 家族共有（世帯単位）
- ダッシュボード（今月の予定・未完了表示）

### 新機能（自動スケジュール・健康アドバイス）
- **自動ワクチンスケジュール生成**: ペットの年齢・犬種に基づいてワクチン接種スケジュールを自動計算
- **投薬スケジュール管理**: 体重に応じた投薬量の自動計算と季節性投薬の管理
- **健康アドバイスシステム**: 犬種・年齢・体重に応じた個別の健康アドバイスを提供
- **日次通知システム**: 毎朝自動でワクチン・投薬・健康アドバイスの通知を生成
- **犬種固有リスク管理**: ダックスフンドの腰・関節トラブルなど、犬種特有のリスクを管理

## 技術スタック

- Ruby 3.2.0
- Rails 7.1.5
- PostgreSQL 15 (jsonb対応)
- Sidekiq (Redis)
- Devise (認証)
- Vanilla JavaScript + CSS + HTML

## セットアップ

### 前提条件

- Ruby 3.2.0
- PostgreSQL 15
- Redis

### インストール

1. リポジトリをクローン
```bash
git clone <repository-url>
cd pet-health2
```

2. 依存関係をインストール
```bash
bundle install
```

3. データベースをセットアップ
```bash
bin/setup
```

4. 開発サーバーを起動
```bash
# ターミナル1: Webサーバー
bin/rails server

# ターミナル2: Sidekiqワーカー
bundle exec sidekiq
```

または、Foremanを使用:
```bash
foreman start -f Procfile.dev
```

### アクセス

- アプリケーション: http://localhost:3000
- テストユーザー: test@example.com / password

## 環境変数

```bash
# データベース
DB_USERNAME=postgres
DB_PASSWORD=
DB_HOST=localhost

# Redis
REDIS_URL=redis://localhost:6379/0
```

## テスト

```bash
# テストを実行
bin/rails test

# システムテスト
bin/rails test:system
```

## 新機能のテスト

### 自動スケジュール生成
```ruby
# ペットのワクチンスケジュールを生成
pet = Pet.first
schedule_builder = ScheduleBuilder.new(pet)
vaccinations = schedule_builder.build_vaccination_schedule

# 投薬スケジュールを生成
medications = schedule_builder.build_medication_schedule
```

### 健康アドバイス
```ruby
# ペットの健康アドバイスを取得
pet = Pet.first
advisor = HealthAdvisor.new(pet)
todays_advice = advisor.get_todays_advice
weekly_advice = advisor.get_weekly_advice
```

### 日次通知ジョブ
```ruby
# 日次通知ジョブを実行
DailyNotificationJob.perform_now
```

### 通知テスト

1. ペットとイベントを登録
2. イベントの日付を明日に設定
3. コンソールで通知ジョブを実行:
```ruby
ReminderEnqueueJob.perform_now
```

## デプロイ

本番環境では以下の環境変数を設定してください:

- `RAILS_MASTER_KEY`
- `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD`, `DB_HOST`
- `REDIS_URL`
- `SMTP_SETTINGS` (メール送信用)

## ライセンス

MIT License
