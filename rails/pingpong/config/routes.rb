Rails.application.routes.draw do
  get 'friends/index'
  root 'home#index'

  get 'stats' , to: "stats#index"
  get 'friends' , to: "friends#index"
  post 'friends/search' , to: "friends#search"
  get 'friends/add', to: "friends#add"
  get 'friends/update', to: "friends#update"
  get 'friends/destroy', to: "friends#destroy"
  get 'friends/search' , to: "friends#search"

  resources :guilds
  post 'guilds/:id/add_officer', to: "guilds#add_officer", as: :add_officer
  post 'guilds/:id/send_invite', to: "guilds#send_invite", as: :send_invite
  post 'guilds/:id/decline_invite', to: "guilds#decline_invite", as: :decline_invite
  post 'guilds/:id/accept_invite', to: "guilds#accept_invite", as: :accept_invite

  get 'games' , to: "games#index"

  resources :profiles

  get 'tournaments' , to: "tournaments#index"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
