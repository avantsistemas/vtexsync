module Export
  class ProtheusController < ApplicationController
    before_action :authenticate

    def clients
      orders_with_payment_approved = find_orders_with_payment_approved
                                     .includes(:client, address: [city: :state])
      if orders_with_payment_approved.length.positive?
        send_data Vtex::Export::Protheus::Clients.new(orders_with_payment_approved)
                                                 .to_txt, filename: filename('clientes')
      else
        render_no_approved_orders_right_now
      end
    end

    def orders
      orders_with_payment_approved = find_orders_with_payment_approved
                                     .includes(:client, :address, :totals, items: [product: :brand,
                                                                                   components: :product],
                                                                           transactions: [payments: :payment_system])
      if orders_with_payment_approved.length.positive?
        send_data Vtex::Export::Protheus::Orders.new(orders_with_payment_approved)
                                                .to_txt, filename: filename('pedidos')
      else
        render_no_approved_orders_right_now
      end
    end

    private

    def find_orders_with_payment_approved
      # Recupera somente os pedidos aprovados há mais de 30 minutos, para evitar
      # recuperar pedidos que ainda estão no período de carência para cancelamento.
      @seller.orders.payment_approved.where('`vtex_orders`.`authorized_date` <= ?', 30.minutes.ago)
    end

    def authenticate
      token_is_present? && seller_exist? && token_is_right?
    end

    def token_is_present?
      return true if params[:chave].present?

      example_url = url_for(only_path: false, chave: 'valor_da_sua_chave')
      render plain: 'Para acessar esse conteúdo é necessário que você informe a sua chave ' \
                    "de acesso, como no exemplo abaixo:\n#{example_url}", status: :bad_request

      false
    end

    def seller_exist?
      seller_identifier = params[:seller]

      @seller = Vtex::Seller.find_by identifier: seller_identifier
      return true if @seller

      render plain: "Esse \"seller\" não existe: #{seller_identifier}", status: :bad_request

      false
    end

    def token_is_right?
      seller_token = params[:chave]

      return true if @seller.token == seller_token

      render plain: "Chave \"#{seller_token}\" incorreta para #{@seller.identifier}", status: :unauthorized

      false
    end

    def filename(basename)
      timestamp = Time.current.strftime('%y%m%d_%H%M%S')
      "#{basename}_#{timestamp}.txt"
    end

    def render_no_approved_orders_right_now
      render plain: 'Não há nenhum pedido com status "Pagamento Aprovado" nesse momento'
    end
  end
end
