class WebhooksController < ApplicationController
  def orders
    if params[:hookConfig] == 'ping'
      logger.info "Ping da VTEX no webhook de pedidos: #{params}"
    else
      logger.info "Webhook de pedidos acionado com o payload #{params}"
      Vtex::Order::SyncJob.set(priority: 0).perform_later(params['OrderId'])
    end
  end
end
