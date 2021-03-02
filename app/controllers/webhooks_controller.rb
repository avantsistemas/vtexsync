class WebhooksController < ApplicationController
  def orders
    # Vtex::Order::SyncJob.set(priority: 0).perform_later(params['OrderId']) if params['OrderId'].present?
  end
end
