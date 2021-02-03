class WebhooksController < ActionController::API
  def orders
    payload = params.to_unsafe_h
    logger.info "Webhook de pedidos acionado com o payload #{payload}"
    # SyncOrderJob.set(priority: 0).perform_later(payload)
  end
end
