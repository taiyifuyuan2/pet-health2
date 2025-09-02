# ペット健康管理カレンダー

ペットの予防接種・投薬スケジュールを家族と共有して管理するWebアプリケーションです。

## 機能

- ペット登録（複数頭対応）
- 予定登録（ワクチン/投薬/健診/その他/誕生日）
- メール通知（前日・当日9:00）
- 履歴管理（完了チェック）
- 家族共有（世帯単位）
- ダッシュボード（今月の予定・未完了表示）

## 技術スタック

- Ruby 3.2.0
- Rails 7.1.5
- MySQL 8 (utf8mb4)
- Sidekiq (Redis)
- Devise (認証)
- Vanilla JavaScript + CSS + HTML

## セットアップ

### 前提条件

- Ruby 3.2.0
- MySQL 8
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
DB_USERNAME=root
DB_PASSWORD=
DB_HOST=127.0.0.1

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

## 通知テスト

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
