Rails.application.routes.draw do
  resources :room_messages
  resources :rooms
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
  post 'guilds/:id/leave_guild', to: "guilds#leave_guild", as: :leave_guild
  post 'guilds/:id/kick_member', to: "guilds#kick_member", as: :kick_member
  post 'guilds/:id/remove_officer', to: "guilds#remove_officer", as: :remove_officer
  post 'guilds/:id/send_invite', to: "guild_invites#send_invite", as: :send_invite
  post 'guilds/:id/send_join_request', to: "guild_invites#send_join_request", as: :send_join_request
  post 'guilds/:id/accept_invite', to: "guild_invites#accept_invite", as: :accept_invite
  post 'guilds/:id/decline_invite', to: "guild_invites#decline_invite", as: :decline_invite
  post 'guilds/:id/cancel_invite', to: "guild_invites#cancel_invite", as: :cancel_invite
  post 'guilds/:id/accept_join_request', to: "guild_invites#accept_join_request", as: :accept_join_request
  post 'guilds/:id/decline_join_request', to: "guild_invites#decline_join_request", as: :decline_join_request
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
