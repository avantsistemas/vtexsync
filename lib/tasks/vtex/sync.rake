namespace :vtex do
  task sync: :environment do
    account_name = Rails.configuration.application.vtex[:account_name]
    environment = Rails.configuration.application.vtex[:environment]

    app_token = Rails.application.credentials.vtex[:app_token]
    app_key = Rails.application.credentials.vtex[:app_key]

    api_client = Vtex::Api::Client.new(account_name: account_name, environment: environment,
                                       app_token: app_token, app_key: app_key)

    from = ENV['from'] ? ENV['from'].in_time_zone : 1.day.ago
    to = ENV['to'] ? ENV['to'].in_time_zone : Time.current

    sync_orders = Vtex::Sync::Orders.new(api_client).sync(from: from, to: to)
    Rails.logger.info "Total de pedidos processados: #{sync_orders.processed_orders}"
  end

  task sync_1_day_ago: :environment do
    ENV['from'] = 1.day.ago.as_json
    Rake::Task['vtex:sync'].invoke
  end

  task sync_2_days_ago: :environment do
    ENV['from'] = 2.days.ago.as_json
    Rake::Task['vtex:sync'].invoke
  end

  task sync_1_week_ago: :environment do
    ENV['from'] = 1.week.ago.as_json
    Rake::Task['vtex:sync'].invoke
  end

  task sync_1_month_ago: :environment do
    ENV['from'] = 1.month.ago.as_json
    Rake::Task['vtex:sync'].invoke
  end

  task full_sync: :environment do
    last_order = Vtex::Order.order(:creation_date).last
    from = last_order ? last_order.creation_date + 1.second : 10.years.ago
    ENV['from'] = from.as_json
    Rake::Task['vtex:sync'].invoke
  end
end
