module Export
  class ProtheusController < ApplicationController
    before_action :authenticate

    def clients
      definitively_approved_orders = find_definitively_approved_orders
                                     .includes(:client, address: [city: :state])
      if definitively_approved_orders.length.positive?
        send_data Vtex::Export::Protheus::Clients.new(definitively_approved_orders).to_txt,
                  filename: filename('clientes')
      else
        render_no_approved_orders_right_now
      end
    end

    def orders
      definitively_approved_orders = find_definitively_approved_orders
                                     .includes(:client, :address, items: [:product, components: :product],
                                                                  transactions: [payments: :payment_system])
      if definitively_approved_orders.length.positive?
        send_data Vtex::Export::Protheus::Orders.new(definitively_approved_orders).to_txt,
                  filename: filename('pedidos')
      else
        render_no_approved_orders_right_now
      end
    end

    private

    def find_definitively_approved_orders
      @seller.orders.payment_approved
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
