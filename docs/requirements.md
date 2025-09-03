# ペット健康管理カレンダー 用件定義 v0.9（Rails/utf8mb4）

最終更新: 2025-09-02（JST）
作成目的: 個人開発アプリの要件を“実装に落とせる粒度”まで具体化（Rails + JavaScript + CSS + HTML。Bootstrap等のCSSフレームワークは使わない前提）。DBは MySQL 8 / utf8mb4。

---

## 0. 背景・狙い（簡潔）

* 飼い犬の **予防接種・投薬** スケジュールを **確実に忘れない**。
* 家族と **共有** して「誰がやったかわからない」を解消。
* **外出先** でも履歴・次回予定を即確認。
* ついでに **友人・家族の誕生日** も年1自動通知。

→ MVPは「**カレンダー + 通知 + 履歴**」に集中。

---

## 1. スコープ

### 1.1 MVP

1. ペット登録（複数頭）
2. 予定（イベント）登録：種類（ワクチン/投薬/健診/その他/誕生日）・日付・（任意で時刻）・メモ・リマインド
3. 通知（メール） / アプリ内通知
4. 履歴：完了チェック（1タップ）+ 過去一覧/カレンダー表示
5. 家族共有：同一「世帯」内で共同編集
6. 誕生日（人/ペット）の年次リマインド

### 1.2 ポストMVP（Nice-to-have）

* LINE Notify / Messaging API 連携
* Web Push（PWA）
* 添付（接種証明書・診療明細・体重メモなどの画像）
* Googleカレンダー出力（iCal購読）
* 体重・通院記録の簡易グラフ

---

## 2. ペルソナ要点（要約）

* 30代共働き、外回り多め。忙しくて「手帳」や紙台帳を探すのがストレス。
* ニーズ：忘れない / 履歴をすぐ見たい / 家族で共有したい。

---

## 3. 主要ユースケース

1. **予定登録**：

   * 飼い主はペットの「次回フィラリア（毎月）」や「狂犬病（年1）」を登録
   * 誕生日も登録（家族・友人）
2. **通知受信**：

   * 前日 9:00、当日 9:00 にメール（デフォルト）
3. **当日の実施**：

   * アプリ起動→対象イベントを「完了」にし、メモ（ロット番号など）を残す
4. **履歴参照**：

   * カレンダー上で過去完了が色分け表示
5. **家族共有**：

   * 配偶者を招待リンクで同一「世帯」に参加、互いに編集可

---

## 4. 画面一覧（ワイヤーフレーム要約）

* サインアップ/ログイン
* ダッシュボード（今月の予定・直近の通知・未完了）
* ペット一覧/詳細（ペット切替タブ）
* イベント一覧/詳細/作成・編集（カレンダー + リスト）
* 履歴タブ（過去完了のみ）
* 家族共有（世帯メンバー / 招待リンク発行）
* 設定（通知時刻・既定リマインド・タイムゾーン・LINEトークン）

---

## 5. 非機能 / 技術要件

* 言語: Ruby 3.3+, Rails 7.2+
* DB: **MySQL 8**（utf8mb4 / collation: `utf8mb4_0900_ai_ci`）
* ビルド: Rails標準（Importmap or JS bundlerのどちらでも）
* フロント: 素の **JavaScript + CSS + HTML**（CSSフレームワーク不使用）
* タイムゾーン: `Asia/Tokyo`、i18n: `ja`
* バッチ/ジョブ: Active Job + Sidekiq（Redis）
* 認証: Devise（メール・パスワード）
* メール: Action Mailer（開発: letter\_opener、運用: 任意SMTP）
* 画像保存（ポストMVP）: Active Storage（S3想定）

---

## 6. ドメインモデル（概要）

```
User
 └─ Membership（role: owner/editor/viewer）
Household（世帯）
 ├─ Memberships → Users
 ├─ Pets
 ├─ Contacts（人の誕生日向け）
 └─ Events（subject: Pet or Contact）

Event（予定/実績一体型）
  - subject_type: [Pet, Contact]
  - kind: [vaccine, medication, checkup, other, birthday]
  - title, scheduled_on, scheduled_time(optional)
  - remind_before_minutes (default 1440=前日)
  - remind_second_offset(optional, e.g. 当日9:00固定)
  - status: [pending, completed, skipped]
  - completed_at, note
  - rrule(optional) 例: FREQ=MONTHLY;COUNT=8

NotificationSetting（ユーザー別の受信設定）
  - email_enabled, line_notify_enabled, daily_digest_time

ReminderJob（Sidekiq）
  - 実行時刻に近いイベントへ通知を送信
```

### 6.1 イベント生成戦略

* MVP: **都度登録** 方式 + 必要なら「まとめ作成」（例: フィラリア 4〜12月を一括生成）。
* PostMVP: `rrule` を保存 → 事前展開（将来Nヶ月分を生成）or 実行時オンデマンド評価。

---

## 7. 主要ビジネスルール

* 狂犬病: 原則 年1（自治体により時期案内あり → 手動入力で対応）。
* 混合ワクチン: クリニック方針に依存（例: 年1、または間隔不同）→ タイトル + 次回予定を任意登録。
* フィラリア: 日本だと **4〜12月** に月1が一般的だが地域差あり → ユーザーが開始月・終了月を指定して一括生成。
* 誕生日: FREQ=YEARLY、既定の通知は前日/当日。

---

## 8. 権限・共有

* Household単位のアクセス制御（owner/編集/閲覧）。
* 招待リンク（署名付きトークン、24h有効など）。
* イベント・ペット・連絡先はHousehold配下にスコープ。

---

## 9. データベース設計（テーブル定義案）

### users

* id (PK)
* email (uniq), encrypted\_password
* name
* time\_zone (default: "Asia/Tokyo"), locale ("ja")
* line\_notify\_token (nullable)
* timestamps

### households

* id (PK), name
* timestamps

### memberships

* id (PK)
* user\_id (FK), household\_id (FK)
* role (enum: owner/editor/viewer)
* uniq index: \[user\_id, household\_id]
* timestamps

### pets

* id (PK), household\_id (FK)
* name, species ("dog"/"cat"/other), sex (nullable), birthday (date, nullable)
* photo (Active Storage, PostMVP)
* notes (text)
* timestamps

### contacts（人の誕生日用）

* id (PK), household\_id (FK)
* name, birthday(date)
* relation (friend/family/other)
* notes (text)
* timestamps

### events

* id (PK), household\_id (FK)
* subject\_type ("Pet"/"Contact"), subject\_id (FK)
* kind (enum: vaccine/medication/checkup/other/birthday)
* title (string)
* scheduled\_on (date), scheduled\_time (time, nullable)
* rrule (string, nullable)
* remind\_before\_minutes (int, default: 1440)
* status (enum: pending/completed/skipped, default: pending)
* completed\_at (datetime, nullable)
* note (text)
* indexes: \[household\_id, scheduled\_on], \[subject\_type, subject\_id], \[kind]
* timestamps

### notification\_settings

* id (PK), user\_id (FK)
* email\_enabled (bool, default: true)
* line\_notify\_enabled (bool, default: false)
* daily\_digest\_time (time, nullable)  # 毎朝まとめ通知
* timestamps

---

## 10. ルーティング（概略）

```rb
Rails.application.routes.draw do
  devise_for :users

  resource :dashboard, only: :show

  resources :households, only: [:show, :update] do
    resources :memberships, only: [:index, :create, :update, :destroy]
    post :invitations, to: "invitations#create" # 招待リンク生成
  end

  resources :pets do
    resources :events, shallow: true
  end

  resources :contacts do
    resources :events, shallow: true
  end

  resources :events, only: [:index] # household全体の一覧/カレンダー

  namespace :settings do
    resource :notifications, only: [:show, :update]
  end

  # Webhook（将来: LINEなど）
  # post "/webhooks/line", to: "webhooks#line"

  root "dashboard#show"
end
```

---

## 11. 通知仕様（MVP: メール）

* トリガー: `scheduled_on - remind_before_minutes`、および当日朝9:00（既定）
* 内容: 件名「本日の○○（ペット名/誕生日）のお知らせ」/ 本文にタイトル・対象・完了ボタンURL
* 実装: `ReminderEnqueueJob`（cron/sidekiq-scheduler）→ `EventMailer` 送信

> PostMVP: LINE Notify（ユーザー設定でON、個人トークへPOST）/ Web Push（Service Worker + VAPID）

---

## 12. 文字コード/DB 設定（utf8mb4）

### Gemfile

```rb
gem "mysql2", ">= 0.5"
# ジョブ基盤
gem "sidekiq"
# 認証
gem "devise"
# 開発用
gem "letter_opener", group: :development
```

### config/database.yml（例）

```yml
default: &default
  adapter: mysql2
  encoding: utf8mb4
  collation: utf8mb4_0900_ai_ci
  pool: <%= ENV.fetch("RAILS_MAX_THREADS", 5) %>
  username: <%= ENV.fetch("DB_USERNAME", "root") %>
  password: <%= ENV.fetch("DB_PASSWORD", "") %>
  host: <%= ENV.fetch("DB_HOST", "127.0.0.1") %>
  variables:
    sql_mode: TRADITIONAL

development:
  <<: *default
  database: pet_health_dev

test:
  <<: *default
  database: pet_health_test

production:
  <<: *default
  database: <%= ENV["DB_NAME"] %>
  username: <%= ENV["DB_USERNAME"] %>
  password: <%= ENV["DB_PASSWORD"] %>
  host: <%= ENV["DB_HOST"] %>
```

### MySQL 作成例

```bash
mysql -u root -p -e "CREATE DATABASE pet_health_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
```

> **補足**: MySQL 8 では 191 文字制限は実質解消（innodb\_large\_prefix既定ON）。長い索引用カラムは必要に応じて `index: { length: 191 }` を付与。

---

## 13. モデル/マイグレーション雛形

```rb
# rails g model Household name:string
# rails g model Membership user:references household:references role:integer
# rails g model Pet household:references name:string species:string sex:string birthday:date notes:text
# rails g model Contact household:references name:string birthday:date relation:string notes:text
# rails g model Event household:references subject:references{polymorphic} kind:integer title:string \
#   scheduled_on:date scheduled_time:time rrule:string remind_before_minutes:integer status:integer \
#   completed_at:datetime note:text
# rails g model NotificationSetting user:references email_enabled:boolean line_notify_enabled:boolean daily_digest_time:time
```

```rb
# app/models/event.rb
class Event < ApplicationRecord
  enum kind: { vaccine: 0, medication: 1, checkup: 2, other: 3, birthday: 4 }
  enum status: { pending: 0, completed: 1, skipped: 2 }

  belongs_to :household
  belongs_to :subject, polymorphic: true # Pet or Contact

  scope :due_between, ->(from, to) {
    where(scheduled_on: from..to)
  }

  def due_at
    # 当日通知時刻（9:00 JST）を仮決め
    if scheduled_time.present?
      Time.zone.parse("#{scheduled_on} #{scheduled_time}")
    else
      Time.zone.parse("#{scheduled_on} 09:00")
    end
  end
end
```

```rb
# app/jobs/reminder_enqueue_job.rb
class ReminderEnqueueJob < ApplicationJob
  queue_as :default

  # 毎時実行: 直近24h内で通知すべきイベントを拾う
  def perform
    now = Time.zone.now
    horizon = now + 24.hours
    Event.pending.due_between(now.to_date, horizon.to_date).find_each do |event|
      # 前日通知（remind_before_minutes）
      remind_time = event.due_at - event.remind_before_minutes.minutes
      if remind_time.between?(now - 5.minutes, now + 55.minutes)
        ReminderDeliverJob.perform_later(event.id, :pre)
      end
      # 当日朝9時通知
      if event.due_at.change(hour: 9, min: 0).between?(now - 5.minutes, now + 55.minutes)
        ReminderDeliverJob.perform_later(event.id, :day)
      end
    end
  end
end
```

```rb
# app/jobs/reminder_deliver_job.rb
class ReminderDeliverJob < ApplicationJob
  queue_as :mailers

  def perform(event_id, phase)
    event = Event.find(event_id)
    event.household.memberships.includes(:user).each do |m|
      user = m.user
      setting = user.notification_setting || NotificationSetting.new(email_enabled: true)
      if setting.email_enabled?
        EventMailer.with(user:, event:, phase:).notify.deliver_now
      end
      # PostMVP: LINE Notify / Web Push
    end
  end
end
```

```rb
# app/mailers/event_mailer.rb
class EventMailer < ApplicationMailer
  def notify
    @user = params[:user]
    @event = params[:event]
    @phase = params[:phase] # :pre or :day
    mail(to: @user.email, subject: "【お知らせ】#{@event.title}（#{@event.scheduled_on}）")
  end
end
```

---

## 14. 受け入れ条件（例）

* 登録済みのフィラリア予定（毎月 5日 9:00 / remind=前日）について、

  * 前日 9:00 に household全メンバーへメールが届く
  * 当日 9:00 にもメールが届く
  * ユーザーが「完了」を押すと status=completed, completed\_at 記録
  * カレンダーでは「完了」表示に色分け

---

## 15. 実装タスク（短期スプリント例）

**Day 1-2**: Rails新規作成（MySQL接続/utf8mb4）/ Devise / Household & Membership / Dashboard 雛形

**Day 3-4**: Pet/Contact/Event モデル + CRUD（簡易ビュー: Rails form\_with + 素のCSS）

**Day 5**: メール通知（Mailer + Sidekiq）/ 1時間ごとのジョブ

**Day 6**: カレンダー（最初は月次テーブルUI）+ 履歴表示

**Day 7**: 家族招待リンク / 権限 / 受け入れテスト / 本番デプロイ

---

## 16. UI 指針（CSSは素で）

* ベースは白背景 + グレーの罫線、フォントは system-ui。
* 主要操作（予定追加、完了ボタン）は 44px 以上のタップ領域。
* カラー: 予定の種類ごとに色分け（例）

  * vaccine: #1e90ff / medication: #2ecc71 / checkup: #f39c12 / other: #7f8c8d / birthday: #e91e63
* カレンダー: 今月/来月切替、今日ハイライト、未完了は点線枠。

---

## 17. 面接で語る一言（準備用）

> 「汎用カレンダーでは“ペット特有の情報”や“家族共有”が弱く、忙しいと結局忘れてしまう。そこで、**カレンダー×通知×履歴**に絞って“忘れない安心”と“外でも即確認”を作り込みました。Rails + MySQL（utf8mb4）で堅実に、通知ジョブ/世帯共有までMVPに含めています。」

---

## 18. 今後の拡張

* 体重・通院グラフ、添付、LINE/Push、iCal購読、RRULE本実装、医療リマインドのテンプレート配布、ペットプロフィールのQR共有。

---

### 付録: まとめ作成ユースケース（毎月フィラリア）

* 入力: 対象ペット、開始月=4、終了月=12、毎月5日、通知=前日/当日9:00
* 出力: 9件のEventを一括作成（4〜12月）
* 完了: 毎月完了チェックで履歴が蓄積
