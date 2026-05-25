Rails.application.routes.draw do
  root 'home#index'

  get 'up' => 'rails/health#show', as: :rails_health_check

  # namespace :export, path: 'exportar' do
  #   defaults format: :txt do
  #     get ':seller/protheus/clientes', to: 'protheus#clients'
  #     get ':seller/protheus/pedidos', to: 'protheus#orders'
  #   end
  # end

  get 'debug', to: 'debug#show'
  get 'debug/jobs', to: 'debug#jobs'

  namespace :webhooks do
    post 'orders'
  end
end
