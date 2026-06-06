class WebhooksController < ApplicationController
  def orders
    return head :bad_request if params['OrderId'].blank?

    Vtex::Sync::OrderJob.perform_later(params['OrderId'])
    head :accepted
  end
end
