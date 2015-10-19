Rails.application.routes.draw do
  resources :chat
  get '/chats/:username', to: 'chat#show_all'
end
