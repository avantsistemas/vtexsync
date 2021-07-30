module Vtex
  class Order
    class NotifyPostAffiliateProJob < ApplicationJob
      queue_as :vtex_order_notify_post_affiliate_pro
      queue_with_priority JobPriority::LOWER

      def perform(order)
        logger.tagged(order.order_code) { notify_post_affiliate_pro(order) }
      end

      private

      def notify_post_affiliate_pro(order)
        response = request_post_affiliate_pro(order)
        inspected_response = inspect_response(response)

        raise HTTP::RequestError, inspected_response unless response.status.ok?

        Rails.logger.info { inspected_response }
      end

      def request_post_affiliate_pro(order)
        url = if order.status == 'payment-approved'
                post_affiliate_pro_approve_url(order)
              elsif order.status == 'canceled'
                post_affiliate_pro_decline_url(order)
              else
                raise 'somente os estados `payment-approved` e `canceled` podem ser notificados ' \
                      "(#{order.inspect}, status = #{order.status}"
              end

        HTTP.get(url)
      end

      def post_affiliate_pro_approve_url(order)
        approve_url = post_affiliate_pro_configuration[:approve_url]
        post_affiliate_order_code = post_affiliate_pro_order_code_for(order)
        approve_url % post_affiliate_order_code
      end

      def post_affiliate_pro_decline_url(order)
        decline_url = post_affiliate_pro_configuration[:decline_url]
        post_affiliate_order_code = post_affiliate_pro_order_code_for(order)
        decline_url % post_affiliate_order_code
      end

      def post_affiliate_pro_configuration
        Rails.application.credentials.post_affiliate_pro
      end

      def post_affiliate_pro_order_code_for(order)
        order_code = order.order_code
        order_code[0, order_code.index('-') - 1]
      end

      def inspect_response(response)
        "#{response.uri} => #{response.status} #{response.body}"
      end
    end
  end
end
