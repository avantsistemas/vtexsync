class WebhooksController < ApplicationController
  def orders
    return head :bad_request if params['OrderId'].blank?

    Vtex::Order::SyncJob.perform_later(params['OrderId'])
    head :accepted
  end
end
