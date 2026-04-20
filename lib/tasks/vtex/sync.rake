# frozen_string_literal: true

namespace :vtex do
  task sync_orders: :environment do
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
    Rake::Task['vtex:sync_orders'].invoke
  end

  task sync_2_days_ago: :environment do
    ENV['from'] = 2.days.ago.as_json
    Rake::Task['vtex:sync_orders'].invoke
  end

  task sync_1_week_ago: :environment do
    ENV['from'] = 1.week.ago.as_json
    Rake::Task['vtex:sync_orders'].invoke
  end

  task sync_1_month_ago: :environment do
    ENV['from'] = 1.month.ago.as_json
    Rake::Task['vtex:sync_orders'].invoke
  end

  task full_sync: :environment do
    last_order = Vtex::Order.order(:creation_date).last
    from = last_order ? last_order.creation_date + 1.second : 10.years.ago
    ENV['from'] = from.as_json
    Rake::Task['vtex:sync_orders'].invoke
  end

  task sync_order: :environment do
    account_name = Rails.configuration.application.vtex[:account_name]
    environment = Rails.configuration.application.vtex[:environment]

    app_token = Rails.application.credentials.vtex[:app_token]
    app_key = Rails.application.credentials.vtex[:app_key]

    api_client = Vtex::Api::Client.new(account_name: account_name, environment: environment,
                                       app_token: app_token, app_key: app_key)

    order_id = ENV.fetch('order_id')
    Vtex::Sync::Order.new(api_client).sync(order_id)
  end

  task sync_sales_channel: :environment do
    require 'ruby-progressbar'

    wait_time_on_rate_limit = 120 # segundos
    request_delay = 2 # segundos

    account_name = Rails.configuration.application.vtex[:account_name]
    environment = Rails.configuration.application.vtex[:environment]

    app_token = Rails.application.credentials.vtex[:app_token]
    app_key = Rails.application.credentials.vtex[:app_key]

    api_client = Vtex::Api::Client.new(account_name: account_name, environment: environment,
                                       app_token: app_token, app_key: app_key)

    orders_without_sales_channel = Vtex::Order.where(sales_channel: nil, hostname: nil)

    progressbar = ProgressBar.create(total: orders_without_sales_channel.count,
                                     format: '%a %e %P% Processed: %c from %C')

    orders_without_sales_channel.find_each do |order_without_sales_channel|
      loop do
        response = api_client.get_order(order_without_sales_channel.order_code)
        order_without_sales_channel.update_columns(sales_channel: response['salesChannel'],
                                                   hostname: response['hostname'])
        progressbar.increment
        sleep(request_delay)
        break
      rescue StandardError => e
        if e.message.include?('500') && e.message.include?('MaxRequestsByInstance')
          progressbar.log "[RATE LIMIT] Pedido #{order_without_sales_channel.order_code} — aguardando " \
                          "#{wait_time_on_rate_limit}s e tentando novamente..."
          sleep(wait_time_on_rate_limit)
        else
          progressbar.log "[ERRO] Pedido #{order_without_sales_channel.order_code}: #{e.message} — pulando."
          progressbar.increment
          break
        end
      end
    end
  end
end
