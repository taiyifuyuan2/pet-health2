Rails.application.routes.draw do
  devise_for :users

  get 'dashboard', to: 'dashboard#show'
  get 'mypage', to: 'users#show'
  get 'mypage/edit', to: 'users#edit'
  patch 'mypage', to: 'users#update'

  resources :households, only: [:show, :new, :create, :edit, :update] do
    resources :memberships, only: [:index, :create, :update, :destroy]
    post :invitations, to: "invitations#create" # 招待リンク生成
  end

  resources :events, only: [:index, :show, :new, :create, :edit, :update, :destroy] do # household全体の一覧/カレンダー
    member do
      patch :complete
    end
  end

  resources :pets, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :events, shallow: true
  end

  resources :contacts, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :events, shallow: true
  end



  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#show"
end
