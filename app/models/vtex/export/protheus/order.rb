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
            payment_information
          ]
        end

        def calculate_payment_information
          payment_system_groups = group_transactions_by_payment_system_groups
          if payment_system_groups.include? 'bankInvoice'
            "B#{payment_system_groups['bankInvoice']}"
          elsif payment_system_groups.include? 'creditCard'
            "C#{payment_system_groups['creditCard']}"
          end
        end

        def group_transactions_by_payment_system_groups
          payment_system_groups = Hash.new(0)

          @order.transactions.each do |transaction|
            transaction.payments.each do |payment|
              payment_system = payment.payment_system
              payment_system_group = payment_system.group
              payment_system_groups[payment_system_group] += 1
            end
          end

          payment_system_groups
        end
      end
    end
  end
end
