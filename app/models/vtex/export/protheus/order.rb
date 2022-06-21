module Vtex
  module Export
    module Protheus
      class Order < Exportable
        def initialize(order)
          @order = order
          @item_sequence = 0
        end

        def to_txt
          super + "\n" + OrderItems.new(@order.items, protheus_order: self).to_txt
        end

        def limited_order_code
          @order.order_code[0..9]
        end

        def client_document
          @order.client.document
        end

        def client_postal_code
          @order.address.postal_code.gsub(/\W/, '')
        end

        def payment_information
          calculate_payment_information
        end

        def brand_identification
          @order.items.first.product.brand.name.first
        end

        def next_item_sequence
          @item_sequence += 1
        end

        private

        def data_array
          [
            'A',
            limited_order_code,
            client_document,
            'EC1',
            client_postal_code,
            payment_information,
            brand_identification
          ]
        end

        def calculate_payment_information
          installments_count = count_installments_by_payment_system_groups

          if installments_count.include? 'bankInvoice'
            "B#{installments_count['bankInvoice']}"
          elsif installments_count.include? 'creditCard'
            "C#{installments_count['creditCard']}"
          elsif installments_count.include? 'instantPayment'
            "P#{installments_count['instantPayment']}"
          elsif installments_count.include? 'Nubank'
            "N#{installments_count['Nubank']}"
          end
        end

        def count_installments_by_payment_system_groups
          installments_count = Hash.new(0)

          @order.transactions.each do |transaction|
            transaction.payments.each do |payment|
              payment_system = payment.payment_system
              payment_system_group = payment_system.group
              installments_count[payment_system_group] += payment.installments
            end
          end

          installments_count
        end
      end
    end
  end
end
