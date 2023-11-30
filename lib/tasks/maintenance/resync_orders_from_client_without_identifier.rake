namespace :maintenance do
  # Sincroniza novamente os pedidos de clientes com identificador nulo. O identificador do cliente em pedidos do
  # Mercado Livre estava vindo nulo e, por conta disso, todos eles acabaram sendo vinculados a um único cliente
  # cujo ID é 102558.
  task resync_orders_from_client_without_identifier: :environment do
    account_name = Rails.configuration.application.vtex[:account_name]
    environment = Rails.configuration.application.vtex[:environment]

    app_token = Rails.application.credentials.vtex[:app_token]
    app_key = Rails.application.credentials.vtex[:app_key]

    api_client = Vtex::Api::Client.new(account_name: account_name, environment: environment,
                                       app_token: app_token, app_key: app_key)

    Vtex::Order.joins(:client).where(vtex_clients: { identifier: nil }).find_each do |order|
      Vtex::Sync::Order.new(api_client).sync(order.order_code)
    end
  end
end
