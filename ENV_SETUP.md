# 環境変数設定ガイド

## 必要な環境変数

### OpenAI API設定
```bash
export OPENAI_API_KEY="your-openai-api-key-here"
```

### データベース設定（開発環境）
```bash
export DATABASE_URL="postgresql://username:password@localhost/pet_health2_development"
```

### Redis設定（Sidekiq用）
```bash
export REDIS_URL="redis://localhost:6379/0"
```

### メール設定（開発環境）
```bash
export SMTP_SERVER="localhost"
export SMTP_PORT="1025"
export SMTP_USERNAME=""
export SMTP_PASSWORD=""
```

### アプリケーション設定
```bash
export RAILS_ENV="development"
export SECRET_KEY_BASE="your-secret-key-base-here"
```

## 設定方法

### 1. 環境変数ファイルの作成
```bash
# .env ファイルを作成
touch .env

# 環境変数を設定
echo "OPENAI_API_KEY=your-openai-api-key-here" >> .env
echo "DATABASE_URL=postgresql://username:password@localhost/pet_health2_development" >> .env
echo "REDIS_URL=redis://localhost:6379/0" >> .env
```

### 2. Rails credentials を使用する場合
```bash
# credentials を編集
rails credentials:edit

# 以下の内容を追加
openai_api_key: your-openai-api-key-here
```

### 3. 本番環境での設定
本番環境では、デプロイ先のプラットフォーム（Heroku、AWS、など）の環境変数設定機能を使用してください。

## OpenAI API キーの取得方法

1. [OpenAI Platform](https://platform.openai.com/) にアクセス
2. アカウントを作成またはログイン
3. API Keys セクションに移動
4. "Create new secret key" をクリック
5. 生成されたキーをコピーして環境変数に設定

## 注意事項

- API キーは機密情報です。Git リポジトリにコミットしないでください
- `.env` ファイルは `.gitignore` に含まれています
- 本番環境では必ず環境変数で設定してください
