Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root to: 'expenses#index'

  resources :debits, :expenses
  resources :tags, only: %i( show edit update ) do
    get 'chart', on: :member
  end
  resources :accounts, except: :show

  namespace :admin do
    get '', to: 'home#index'
    resources :users, only: [:index, :show, :destroy]
  end
end
