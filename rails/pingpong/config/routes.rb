Rails.application.routes.draw do
  get 'friends/index'
  root 'home#index'

  get 'stats' , to: "stats#index"
  get 'friends' , to: "friends#index"
  post 'friends/search' , to: "friends#search"
  post 'friends/add', to: "friends#add"
  get 'friends/search' , to: "friends#search"
  get 'guilds' , to: "guilds#index"
  get 'games' , to: "games#index"
  get 'profile' , to: "profile#index"
  get 'tournaments' , to: "tournaments#index"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
