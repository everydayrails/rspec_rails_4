ContactsExample40::Application.routes.draw do
  resources :news_releases

  get 'signin', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  resources :users
  resources :sessions

  resources :contacts

  root to: 'contacts#index'
end
