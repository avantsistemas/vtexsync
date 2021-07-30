class WebhooksController < ApplicationController
  def orders
    Vtex::Order::SyncJob.perform_later(params['OrderId']) if params['OrderId'].present?
  end
end
