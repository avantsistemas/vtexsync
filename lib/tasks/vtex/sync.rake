namespace :vtex do
  task sync: :environment do
    account_name = 'bioextratusvirtual'
    environment = 'vtexcommercestable'

    app_token = 'WEWDEGDSXYFMEJPUPLIKWGMGVXAJKEWPIBUIPIVBNMLCSQPJFHIFOFLPSPHHFUHT' \
                'BPDDPHFGPGWJVJOFIQDDVRBDPEPAAOWSESACMLUYBBPHIBUIACYPREXKOANKRFFB'

    app_key = 'vtexappkey-bioextratusvirtual-EBQXOV'

    api_client = Vtex::Api::Client.new(account_name: account_name, environment: environment,
                                       app_token: app_token, app_key: app_key)

    creation_date_range = 1.hour.ago..Time.current

    http_client_method_arguments = { creation_date_range: creation_date_range,
                                     params: { orderBy: 'creationDate,asc' } }

    Rails.logger.info "Listando pedidos cadastrados no período #{creation_date_range}"
    processed_orders_count = 0

    page = Vtex::Api::Page.paginate(api_client: api_client, client_method: :list_orders,
                                    method_args: http_client_method_arguments)

    while page.next?
      result = page.next
      result['list'].each do |order_attributes|
        order_id = order_attributes['orderId']
        Vtex::Sync::Order.new(api_client).sync(order_id)
        processed_orders_count += 1
      end
    end

    Rails.logger.info "Pedidos processados: #{processed_orders_count}"
  end
end
