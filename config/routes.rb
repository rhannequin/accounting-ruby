Rails.application.routes.draw do
  resources :debits, :expenses
  resources :tags, only: %i( show edit update ) do
    get 'chart', on: :member
  end
  get 'test', to: 'expenses#test'
  root to: 'expenses#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
