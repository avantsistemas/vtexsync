namespace :vtex do
  task sync_orders: :environment do
    from = ENV['from'] ? ENV['from'].in_time_zone : 1.day.ago
    to = ENV['to'] ? ENV['to'].in_time_zone : Time.current

    api_client = Vtex::Api::Client.build
    sync_orders = Vtex::Sync::Orders.new(api_client).sync(from: from, to: to)
    puts "Total de pedidos processados: #{sync_orders.processed_orders}"
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
    order_id = ENV.fetch('order_id')
    api_client = Vtex::Api::Client.build
    Vtex::Sync::Order.new(api_client).sync(order_id)
  end

  task mark_for_resync: :environment do
    order_codes = ENV['order_ids'].to_s.split(',').map(&:strip).reject(&:empty?)
    affected = Vtex::Orders::ResyncMarker.call(
      order_codes: order_codes,
      scope: ENV.fetch('scope', nil),
      from: ENV['from']&.in_time_zone,
      to: ENV['to']&.in_time_zone,
      reason: ENV.fetch('reason', nil)
    )
    puts "Pedidos marcados para re-sincronização: #{affected}"
  end

  task enqueue_resync: :environment do
    result = Vtex::Orders::ResyncEnqueuer.call(limit: ENV['limit']&.to_i)
    puts "Enfileirando re-sincronização para #{result[:total]} pedido(s)"
    puts "Total de pedidos enfileirados: #{result[:enqueued]}"
  end
end
