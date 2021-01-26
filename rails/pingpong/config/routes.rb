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
  post 'guilds/:id/send_invite', to: "guild_invites#send_invite", as: :send_invite
  post 'guilds/:id/accept_invite', to: "guild_invites#accept_invite", as: :accept_invite
  post 'guilds/:id/cancel_invite', to: "guild_invites#cancel_invite", as: :cancel_invite
  post 'guilds/:id/accept_join_request', to: "guild_invites#accept_join_request", as: :accept_join_request
  post 'guilds/:id/cancel_join_request', to: "guild_invites#cancel_join_request", as: :cancel_join_request
  

  get 'games' , to: "games#index"

  resources :profiles

  get 'tournaments' , to: "tournaments#index"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
