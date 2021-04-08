Rails.application.routes.draw do
  resources :room_messages
  resources :rooms
  resources :direct_messages
  resources :direct_rooms

  post	'direct_messages', to: 'direct_messages#create', as: :create_dir_message
  get   'otp_secrets', to: 'otp_secrets#new'
  get   'otp_secrets/login', to: 'otp_secrets#login'
  post   'otp_secrets/auth_logger', to: 'otp_secrets#auth_logger', as: :otp_secrets_logger

  post   'otp_secrets', to: 'otp_secrets#create'
  post   'otp_secrets/destroy', to: 'otp_secrets#destroy'

  get  'rooms/:id/users', to: 'rooms#user_list',  as: :rooms_users
  get  'rooms/:id/settings', to: 'rooms#room_settings',  as: :room_settings
  post 'rooms/password_enter', to: "rooms#password_enter", as: :rooms_password_enter
  post 'rooms/:id/leave', to: "chat_room_members#leave", as: :chat_room_members_leave
  post 'rooms/:id/kick', to: "chat_room_members#kick", as: :chat_room_members_kick
  post 'rooms/:id/new', to: "chat_room_members#new", as: :new_room_member
  post 'rooms/:id/create', to: "chat_room_members#create", as: :join_room_pass
  post 'rooms/:id/ban', to: "chat_room_members#ban", as: :ban_chat_member
  post 'rooms/:id/unban', to: "chat_room_members#unban", as: :unban_chat_member
  post 'rooms/:id/mute', to: "chat_room_members#mute", as: :mute_chat_member
  post 'rooms/:id/unmute', to: "chat_room_members#unmute", as: :unmute_chat_member
  post 'rooms/:id/add_adm', to: "chat_room_members#make_admin", as: :add_adm_member
  post 'rooms/:id/remove_adm', to: "chat_room_members#remove_admin", as: :remove_adm_member
  post 'block', to: "chat_room_members#block", as: :block
  post 'unblock', to: "chat_room_members#unblock", as: :unblock
  delete "/rooms/:id", to: "rooms#destroy", as: :destroy_room

  post 'direct/:id/block', to: "direct_rooms#block", as: :direct_block
  post 'direct/:id/unblock', to: "direct_rooms#unblock", as: :direct_unblock

  post 'direct', to: "direct_rooms#find_room", as: :direct_rooms_find

  get 'friends/index'
  root 'home#index'

  get 'stats' , to: "stats#index"
  get 'friends' , to: "friends#index"
  post 'friends/search' , to: "friends#search"
  get 'friends/add', to: "friends#add"
  get 'friends/update', to: "friends#update"
  get 'friends/destroy', to: "friends#destroy"
  get 'friends/search' , to: "friends#search"

  resources :guilds, only: [:index, :show, :new, :create]
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

  resources :games, only: [:index, :show, :new, :create]
  post 'games/:id/join_player', to: "games#join_player", as: :game_join_player
  post 'games/:id/switch_ready', to: "games#switch_ready", as: :game_switch_ready
  post 'games/:id/leave_player', to: "games#leave_player", as: :game_leave_player
  post 'games/wartime_game_create', to: "games#wartime_game_create", as: :wartime_game_create

  resources :profiles, only: [:index, :show, :edit]

  resources :tournaments, only: [:new, :create, :index, :destroy]

  post 'tournaments/:id/register', to: "tournaments#register", as: :tournament_register
  post 'tournaments/:id/unregister', to: "tournaments#unregister", as: :tournament_unregister

  get 'guilds/:id/wars', to: "wars#index", as: :guild_wars_index
  get 'guilds/wars/:id', to: "wars#show", as: :guild_wars_show
  get 'guilds/war/new', to: "wars#new", as: :guild_wars_new
  post 'guilds/wars', to: "wars#create", as: :guild_wars_create
  post 'guilds/wars/:id/accept_war_request', to: "wars#accept_war_request", as: :guild_wars_accept_war_request
  post 'guilds/wars/:id/cancel_war_request', to: "wars#cancel_war_request", as: :guild_wars_cancel_war_request
  post 'guilds/wars/:id/decline_war_request', to: "wars#decline_war_request", as: :guild_wars_decline_war_request
  post 'guilds/wars/:id/leave', to: "wars#leave", as: :guild_wars_leave

  devise_for :users, controllers: { sessions: 'sessions', omniauth_callbacks: "users/omniauth_callbacks", registrations: "registrations" }

  devise_scope :user do
	get '/users', to: 'devise/registrations#edit'
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
