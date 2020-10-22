namespace :vtex do
  task sync: :environment do
    account_name = 'bioextratusvirtual'
    environment = 'vtexcommercestable'

    app_token = Rails.application.credentials.vtex[:bioextratus][:app_token]
    app_key = Rails.application.credentials.vtex[:bioextratus][:app_key]

    api_client = Vtex::Api::Client.new(account_name: account_name, environment: environment,
                                       app_token: app_token, app_key: app_key)

    sync_orders = Vtex::Sync::Orders.new(api_client).sync(since: 1.day.ago)
    Rails.logger.info "Total de pedidos processados: #{sync_orders.processed_orders}"
  end
end
