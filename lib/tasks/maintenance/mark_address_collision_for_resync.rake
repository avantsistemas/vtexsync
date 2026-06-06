namespace :maintenance do
  # Backfill pontual: marca para resync os pedidos afetados pela colisão de endereços anterior à correção que passou
  # a tratar endereços sem +addressId+ UUID como informação transacional (veja Vtex::Sync::Models::Address). O escopo
  # são os endereços não-UUID que agregam pedidos de clientes distintos — onde endereços diferentes colidiram num só.
  # Ao re-sincronizar, cada pedido recria seu próprio endereço, desfazendo a colisão. Depois, rode vtex:enqueue_resync
  # para enfileirar a re-sincronização em ondas (drip-feed), respeitando o cooldown da API da VTEX.
  desc 'Marca para resync os pedidos com endereço colidido (não-UUID compartilhado por clientes distintos)'
  task mark_address_collision_for_resync: :environment do
    uuid = '^[a-fA-F0-9]{32}$'
    uuid_dashed = '^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$'
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch('DRY_RUN', 'true'))

    colliding_address_ids = Vtex::Order
                            .joins(:address)
                            .where.not('vtex_addresses.identifier REGEXP ?', uuid)
                            .where.not('vtex_addresses.identifier REGEXP ?', uuid_dashed)
                            .group(:address_id)
                            .having('COUNT(DISTINCT vtex_orders.client_id) > 1')
                            .pluck(:address_id)

    scope = Vtex::Order.where(address_id: colliding_address_ids)

    puts "Endereços colididos: #{colliding_address_ids.size}"
    puts "Pedidos no escopo: #{scope.count}"
    puts "Dry run: #{dry_run}"

    if dry_run
      puts 'Nenhum pedido foi marcado. Rode com DRY_RUN=false para marcar.'
      next
    end

    affected = scope.update_all(resync_requested_at: Time.current, resync_reason: 'address_collision_backfill')
    puts "Pedidos marcados para re-sincronização: #{affected}"
  end
end
