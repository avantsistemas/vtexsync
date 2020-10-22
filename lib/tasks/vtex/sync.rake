namespace :vtex do
  task sync: :environment do
    account_name = 'bioextratusvirtual'
    environment = 'vtexcommercestable'

    app_token = Rails.application.credentials.vtex[:bioextratus][:app_token]
    app_key = Rails.application.credentials.vtex[:bioextratus][:app_key]

    api_client = Vtex::Api::Client.new(account_name: account_name, environment: environment,
                                       app_token: app_token, app_key: app_key)

    # creation_date_from = Vtex::Order.maximum(:creation_date) || Time.current.at_beginning_of_year
    # creation_date_from = 1.day.ago if creation_date_from > 1.month.ago
    creation_date_from = 1.hour.ago

    creation_date_range = creation_date_from..Time.current

    http_client_method_arguments = { creation_date_range: creation_date_range,
                                     params: { orderBy: 'creationDate,asc',
                                               per_page: 100_000 } }

    Rails.logger.info "Listando pedidos cadastrados no período #{creation_date_range}"
    processed_orders_count = 0

    page = Vtex::Api::Page.paginate(api_client: api_client, client_method: :list_orders,
                                    method_args: http_client_method_arguments)

    while page.next?
      result = page.next
      result['list'].each do |list_order_attributes|
        order_id = list_order_attributes['orderId']
        Rails.logger.tagged(order_id) do
          vtex_order = Vtex::Order.find_or_initialize_by vtex_code: order_id
          vtex_order.sync_attributes(list_order_attributes)

          if vtex_order.new_record? || vtex_order.changed?
            order_attributes = api_client.get_order(order_id)
            Vtex::Sync::Models::Order.new(order_attributes).sync
          else
            Rails.logger.debug { "#{vtex_order.inspectid} não precisa ser sincronizado(a)" }
          end

          processed_orders_count += 1
        end
      end
    end

    Rails.logger.info "Pedidos processados: #{processed_orders_count}"
  end
end
