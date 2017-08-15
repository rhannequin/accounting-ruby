Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root to: 'home#index'

  resources :accounts do
    resources :debits
    resources :expenses, except: :index
    resources :tags do
      get 'chart', on: :member
    end
  end

  namespace :admin do
    get '', to: 'home#index'
    resources :users, only: %i(index show destroy)
  end
end
