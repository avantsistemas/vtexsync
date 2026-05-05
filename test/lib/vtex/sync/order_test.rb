require 'test_helper'

module Vtex
  module Sync
    class OrderTest < ActiveSupport::TestCase
      class FakeApiClient
        attr_reader :requested_order_ids

        def initialize(order_payload)
          @order_payload = order_payload
          @requested_order_ids = []
        end

        def get_order(order_id)
          requested_order_ids << order_id
          @order_payload
        end
      end

      # This test uses a captured VTEX order payload to exercise the full local
      # synchronization flow without performing HTTP requests. It intentionally
      # checks representative persisted records instead of mirroring every JSON field.
      test 'syncs a captured vtex order payload into the local order graph' do
        order_payload = captured_order_payload
        api_client = FakeApiClient.new(order_payload)
        expected_product_identifiers = order_payload.fetch('items').map { |item| item.fetch('refId') }
        expected_seller_identifiers = order_payload.fetch('sellers').map { |seller| seller.fetch('id') }
        expected_category_identifiers = order_payload.fetch('items').flat_map do |item|
          item.dig('additionalInfo', 'categories').to_a.map { |category| category.fetch('id').to_s }
        end.uniq
        expected_sla_identifiers = order_payload.dig('shippingData', 'logisticsInfo').map do |logistic|
          logistic.fetch('selectedSla')
        end.uniq
        expected_payments = order_payload.dig('paymentData', 'transactions').flat_map do |transaction|
          transaction.fetch('payments')
        end
        expected_payment_system_identifiers = expected_payments.map { |payment| payment.fetch('paymentSystem') }.uniq
        expected_marketing_tag_names = order_payload.dig('marketingData', 'marketingTags')

        order = nil

        assert_difference -> { Vtex::Brand.count }, 1 do
          assert_difference -> { Vtex::Product.count }, expected_product_identifiers.uniq.size do
            assert_difference -> { Vtex::Seller.count }, expected_seller_identifiers.uniq.size do
              assert_difference -> { Vtex::City.count }, 1 do
                order = Vtex::Sync::Order.new(api_client).sync(order_payload.fetch('orderId'))
              end
            end
          end
        end

        assert_equal [order_payload.fetch('orderId')], api_client.requested_order_ids
        assert_predicate order, :persisted?
        assert_equal order_payload.fetch('orderId'), order.order_code
        assert_equal order_payload.fetch('sellerOrderId'), order.seller_order_code
        assert_equal order_payload.fetch('status'), order.status
        assert_equal order_payload.fetch('statusDescription'), order.status_description
        assert_equal BigDecimal(order_payload.fetch('value').to_s) / 100, order.value

        assert_equal order_payload.fetch('clientProfileData').fetch('email'), order.client.email
        assert_equal order_payload.fetch('shippingData').fetch('address').fetch('addressId'), order.address.identifier

        assert_equal order_payload.fetch('items').size, order.items.count
        assert_equal order_payload.fetch('totals').size, order.totals.count
        assert_equal order_payload.dig('shippingData', 'logisticsInfo').size, order.logistics.count
        assert_equal order_payload.fetch('ratesAndBenefitsData').fetch('rateAndBenefitsIdentifiers').size,
                     order.order_benefits.count
        assert_equal order_payload.fetch('paymentData').fetch('transactions').size, order.transactions.count
        assert_equal expected_payments.size, (order.transactions.sum { |transaction| transaction.payments.count })

        assert_equal ['2000003'], Vtex::Brand.pluck(:identifier)
        assert_equal expected_product_identifiers.sort, Vtex::Product.pluck(:identifier).sort
        assert_equal expected_seller_identifiers, Vtex::Seller.pluck(:identifier)
        assert_equal expected_category_identifiers.sort, Vtex::Category.pluck(:identifier).sort
        assert_equal expected_sla_identifiers, Vtex::Sla.pluck(:identifier)
        assert_equal expected_payment_system_identifiers, Vtex::PaymentSystem.pluck(:identifier)
        assert_equal expected_marketing_tag_names, order.campaign.marketing_tags.pluck(:name)
        assert_equal 'Curitiba', order.address.city.name
        assert_equal 'PR', order.address.city.state.acronym
      end

      test 'updates an existing synced order from a newer captured payload' do
        original_payload = captured_order_payload
        original_order = sync_order(original_payload)
        removed_item_identifier = original_payload.fetch('items').last.fetch('uniqueId')
        updated_payload = updated_order_payload(original_payload)

        updated_order = nil

        assert_no_difference -> { Vtex::Order.count } do
          assert_no_difference -> { Vtex::Client.count } do
            assert_no_difference -> { Vtex::Address.count } do
              assert_difference -> { Vtex::OrderItem.count }, -1 do
                assert_difference -> { Vtex::Logistic.count }, -1 do
                  updated_order = sync_order(updated_payload)
                end
              end
            end
          end
        end

        assert_equal original_order.id, updated_order.id
        assert_equal 'payment-approved', updated_order.status
        assert_equal 'Pagamento aprovado', updated_order.status_description
        assert_equal BigDecimal('99.99'), updated_order.value
        assert_equal Time.zone.parse('2020-10-20T12:34:56Z'), updated_order.last_change

        assert_equal 'cliente.atualizado@example.com', updated_order.client.email
        assert_equal 'Cliente Atualizado', updated_order.address.receiver_name
        assert_equal updated_payload.fetch('items').size, updated_order.items.count
        assert_empty updated_order.items.where(identifier: removed_item_identifier)
        assert_equal updated_payload.dig('shippingData', 'logisticsInfo').size, updated_order.logistics.count

        payment = updated_order.transactions.first.payments.first

        assert_equal 1, payment.installments
        assert_equal BigDecimal('99.99'), payment.value
        assert_equal ['Pedido Atualizado'], updated_order.campaign.marketing_tags.pluck(:name)
      end

      private

      def captured_order_payload
        JSON.parse(Rails.root.join('test/fixtures/files/get_order_bioextratus.json').read)
      end

      def sync_order(order_payload)
        Vtex::Sync::Order.new(FakeApiClient.new(order_payload)).sync(order_payload.fetch('orderId'))
      end

      def updated_order_payload(order_payload)
        order_payload.deep_dup.tap do |payload|
          payload['status'] = 'payment-approved'
          payload['statusDescription'] = 'Pagamento aprovado'
          payload['value'] = 9999
          payload['lastChange'] = '2020-10-20T12:34:56Z'
          payload['clientProfileData']['email'] = 'cliente.atualizado@example.com'
          payload['shippingData']['address']['receiverName'] = 'Cliente Atualizado'
          payload['items'] = payload.fetch('items').first(2)
          payload['shippingData']['logisticsInfo'] = payload.dig('shippingData', 'logisticsInfo').first(2)
          payload['paymentData']['transactions'][0]['payments'][0]['installments'] = 1
          payload['paymentData']['transactions'][0]['payments'][0]['value'] = 9999
          payload['marketingData']['marketingTags'] = ['Pedido Atualizado']
        end
      end
    end
  end
end
