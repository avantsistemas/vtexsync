namespace :vtex do
  task sync: :environment do
    account_name = 'bioextratusvirtual'
    environment = 'vtexcommercestable'

    app_token = Rails.application.credentials.vtex[:bioextratus][:app_token]
    app_key = Rails.application.credentials.vtex[:bioextratus][:app_key]

    api_client = Vtex::Api::Client.new(account_name: account_name, environment: environment,
                                       app_token: app_token, app_key: app_key)

    Vtex::Sync::Orders.new(api_client).sync(since: 1.day.ago)
  end
end
