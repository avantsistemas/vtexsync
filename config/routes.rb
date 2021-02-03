Rails.application.routes.draw do
  root 'home#index'

  namespace :webhooks do
    post 'orders'
  end
end
