Rails.application.routes.draw do
  devise_for :users

  get 'dashboard', to: 'dashboard#show'
  get 'mypage', to: 'users#show'
  get 'mypage/edit', to: 'users#edit'
  patch 'mypage', to: 'users#update'

  # 招待受け入れ用のルート（householdsより前に定義）
  get 'invitations/:token', to: 'invitations#show', as: :invitation
  post 'invitations/:token/accept', to: 'invitations#accept', as: :accept_invitation

  resources :households, only: %i[show new create edit update destroy] do
    resources :memberships, only: %i[index create update destroy]
    resources :invitations, only: %i[create]
  end

  resources :events, only: %i[index show new create edit update destroy] do # household全体の一覧/カレンダー
    member do
      patch :complete
    end
  end

  resources :pets, only: %i[index show new create edit update destroy] do
    resources :events, shallow: true
    resources :weight_records
    resources :walk_logs

    # AI健康相談機能
    post :ai_question, to: 'ai_health#question'
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  devise_scope :user do
    root 'devise/sessions#new'
  end
end
