namespace :vtex do
  task sync: :environment do
    account_name = 'bioextratusvirtual'
    environment = 'vtexcommercestable'

    app_token = Rails.application.credentials.vtex[:bioextratus][:app_token]
    app_key = Rails.application.credentials.vtex[:bioextratus][:app_key]

    api_client = Vtex::Api::Client.new(account_name: account_name, environment: environment,
                                       app_token: app_token, app_key: app_key)

    from = ENV['from'] ? ENV['from'].in_time_zone : 1.day.ago

    sync_orders = Vtex::Sync::Orders.new(api_client).sync(from: from)
    Rails.logger.info "Total de pedidos processados: #{sync_orders.processed_orders}"
  end

  task sync_1_day_ago: :environment do
    ENV['from'] = 1.hour.ago.as_json
    Rake::Task['vtex:sync'].invoke
  end

  task sync_2_weeks_ago: :environment do
    ENV['from'] = 2.weeks.ago.as_json
    Rake::Task['vtex:sync'].invoke
  end

  task sync_1_month_ago: :environment do
    ENV['from'] = 1.month.ago.as_json
    Rake::Task['vtex:sync'].invoke
  end
end
