Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root to: 'accounts#index'

  resources :debits
  resources :tags, only: %i( show edit update ) do
    get 'chart', on: :member
  end
  resources :accounts do
    resources :expenses, except: :index
  end

  namespace :admin do
    get '', to: 'home#index'
    resources :users, only: [:index, :show, :destroy]
  end
end
