# frozen_string_literal: true

# OpenAI API設定
Rails.application.configure do
  # OpenAI APIキーを環境変数から取得
  # 本番環境では環境変数 OPENAI_API_KEY を設定してください
  config.openai_api_key = ENV['OPENAI_API_KEY'] || Rails.application.credentials.openai_api_key

  # OpenAI APIのタイムアウト設定（秒）
  config.openai_timeout = 30

  # OpenAI APIのリトライ回数
  config.openai_retry_count = 3
end
