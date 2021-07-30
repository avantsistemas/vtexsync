module Vtex
  class Order
    module NotifyPostAffiliatePro
      extend ActiveSupport::Concern

      included do
        after_commit :notify_post_affiliate_pro
      end

      private

      def notify_post_affiliate_pro
        return unless status_previously_changed?
        return unless status == 'payment-approved' || status == 'canceled'
        return unless Rails.configuration.application[:notify_post_affiliate_pro]

        Vtex::Order::NotifyPostAffiliateProJob.perform_later(self)
      end
    end
  end
end
