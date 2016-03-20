Rails.application.routes.draw do
  post '/emails/incoming', to: 'emails#incoming'
  resources :emails
end
