module Vtex
  module Sync
    class Orders
      delegate :logger, to: Rails
      attr_reader :processed_orders

      def initialize(api_client)
        @api_client = api_client
        @processed_orders = 0
      end

      def sync(from: nil, to: Time.current)
        @to = to

        sync_orders_from = from || last_synced_order_creation_date
        sync_orders_period = sync_orders_from..to

        api_client_method_arguments = { creation_date_range: sync_orders_period,
                                        params: { orderBy: 'creationDate,asc',
                                                  per_page: 100_000 } }

        logger.info "Sincronizando pedidos cadastrados no período #{sync_orders_period}"
        page = Vtex::Api::Page.paginate(api_client: api_client, client_method: :list_orders,
                                        method_args: api_client_method_arguments)

        navigate_through_pages_and_sync_orders(page)

        self
      end

      private

      attr_reader :api_client, :last_vtex_order

      def navigate_through_pages_and_sync_orders(api_page)
        while api_page.next? && !api_page.limit_reached?
          page_result = api_page.next
          log_page_info(page_result)
          sync_orders(page_result['list'])
        end

        log_limit_reached and start_a_new_sync if api_page.limit_reached?
      end

      def sync_orders(orders_attributes)
        orders_attributes.each do |order_attributes|
          logger.tagged(order_attributes['orderId']) do
            @last_vtex_order = sync_order_if_needed(order_attributes)
            @processed_orders += 1
          end
        end
      end

      def sync_order_if_needed(minimal_order_attributes)
        attribute_order_id = minimal_order_attributes['orderId']

        vtex_order = Vtex::Order.find_or_initialize_by order_code: attribute_order_id
        vtex_order.sync_attributes(minimal_order_attributes)

        if vtex_order.new_record? || vtex_order.changed?
          full_order_sync(attribute_order_id)
        else
          Logger.log_model_already_synced(vtex_order)
        end

        vtex_order
      end

      def full_order_sync(attribute_order_id)
        Vtex::Sync::Order.new(api_client).call(attribute_order_id)
      end

      def start_a_new_sync
        from = last_vtex_order.creation_date + 1.second
        orders_sync = Orders.new(api_client).sync(from: from, to: @to)
        @processed_orders += orders_sync.processed_orders
      end

      def last_synced_order_creation_date
        Vtex::Order.maximum(:creation_date)
      end

      def log_page_info(page_result)
        current_page = page_result['paging']['currentPage']
        pages_count = page_result['paging']['pages']
        orders_count = page_result['paging']['total']

        message = Logger.colorful_message "Página atual: #{current_page}; Total de páginas: #{pages_count}; " \
                                          "Total de pedidos: #{orders_count}", :cyan

        logger.info message
      end

      def log_limit_reached
        message = Logger.colorful_message("Limite de #{Vtex::Api::Page::VTEX_PAGINATION_LIMIT} páginas " \
                                          'atingido. Uma nova sincronização será iniciada', :yellow)
        logger.info message
      end
    end
  end
end
