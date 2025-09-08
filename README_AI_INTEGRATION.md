# AI統合機能について

このペット健康管理アプリケーションに生成AI機能を統合しました。

## 実装された機能

### 1. AI健康アドバイス
- ペットの個別情報（犬種、年齢、体重、性別）に基づいた個別化された健康アドバイス
- 季節に応じたケアアドバイス
- リアルタイムでのアドバイス生成

### 2. AI健康相談
- ペットの健康に関する質問にAIが回答
- 自然言語での質問が可能
- 緊急時は獣医師受診を推奨

### 3. AI健康分析
- ペットの体重記録、散歩記録などのデータを分析
- 健康状態の総合的な評価
- 改善提案の提供

## 技術仕様

### 使用技術
- **OpenAI GPT-4o-mini**: 生成AIエンジン
- **ruby-openai gem**: OpenAI APIクライアント
- **httparty gem**: HTTP通信サポート

### アーキテクチャ
```
app/
├── services/
│   └── ai_health_advisor.rb      # AI機能のメインサービス
├── controllers/
│   └── ai_health_controller.rb   # AI機能のコントローラー
└── views/
    └── ai_health/                # AI機能のビュー
        ├── _ai_advice.html.erb
        ├── _ai_question_form.html.erb
        ├── _ai_answer.html.erb
        └── _ai_analysis.html.erb
```

## セットアップ

### 1. 環境変数の設定
```bash
# 開発環境
export OPENAI_API_KEY="your-openai-api-key"

# または credentials.yml.enc に設定
rails credentials:edit
```

### 2. 依存関係のインストール
```bash
bundle install
```

### 3. サーバーの起動
```bash
rails server
```

## 使用方法

### AI健康アドバイス
1. ペット詳細ページにアクセス
2. 「AI健康アドバイス」セクションで「AIアドバイスを取得」ボタンをクリック
3. AIがペットの情報を分析して個別化されたアドバイスを生成

### AI健康相談
1. ペット詳細ページの「AI健康相談」セクションで質問を入力
2. 「AIに質問する」ボタンをクリック
3. AIが質問に回答

### AI健康分析
1. ペット詳細ページの「AI健康分析」セクションで「健康分析を実行」ボタンをクリック
2. AIがペットのデータを分析して総合的な健康評価を提供

## API エンドポイント

```
GET  /pets/:pet_id/ai_advice     # AI健康アドバイス取得
POST /pets/:pet_id/ai_question   # AI健康相談
GET  /pets/:pet_id/ai_analysis   # AI健康分析
```

## セキュリティとプライバシー

- OpenAI APIキーは環境変数で管理
- ペットの個人情報は暗号化して送信
- API通信はHTTPSで保護
- ログには機密情報を含まない

## エラーハンドリング

- API接続エラー時はフォールバックメッセージを表示
- ユーザーには分かりやすいエラーメッセージを提供
- ログにエラー詳細を記録

## テスト

```bash
# サービス層のテスト
rspec spec/services/ai_health_advisor_spec.rb

# コントローラー層のテスト
rspec spec/controllers/ai_health_controller_spec.rb

# 全テスト実行
rspec
```

## 今後の拡張予定

- 画像解析による健康状態判定
- 音声での質問対応
- 多言語対応
- より詳細な健康データ分析
- 獣医師との連携機能

## 注意事項

- AIの回答は一般的なアドバイスであり、診断ではありません
- 緊急時や深刻な症状がある場合は必ず獣医師にご相談ください
- API使用量に応じて料金が発生します
