Rails.application.routes.draw do
  root 'home#index'

  namespace :export, path: 'exportar' do
    defaults format: :txt do
      get ':seller/protheus/clientes', to: 'protheus#clients'
    end
  end

  namespace :webhooks do
    post 'orders'
  end
end
