# Reconstrução completa dos pedidos a partir do zero. Fluxo em três etapas,
# cada uma reexecutável de forma independente:
#
#   1. vtex:rebuild:dump_ids   — coleta os orderId da VTEX num arquivo (NÃO destrutivo)
#   2. vtex:rebuild:reset      — zera as tabelas vtex_* e versions (destrutivo)
#   3. vtex:rebuild:enqueue    — enfileira um job de sync por orderId do arquivo
#
# Colete os ids ANTES de zerar o banco: se a coleta falhar, o banco segue intacto.
namespace :vtex do
  namespace :rebuild do
    desc 'Coleta todos os orderId da VTEX e grava num arquivo (retomável; ENV: file, from, to)'
    task dump_ids: :environment do
      path = ENV['file'].presence || Rails.root.join('tmp/order_ids.txt').to_s
      checkpoint_path = "#{path}.checkpoint"
      api_client = Vtex::Api::Client.build
      to = ENV['to'].present? ? ENV['to'].in_time_zone : Time.current

      # Retoma do segundo seguinte ao último creationDate já gravado, salvo
      # quando 'from' é informado explicitamente.
      from =
        if ENV['from'].present?
          ENV['from'].in_time_zone
        elsif File.exist?(checkpoint_path) && File.read(checkpoint_path).strip.present?
          File.read(checkpoint_path).strip.in_time_zone + 1.second
        else
          10.years.ago
        end

      collected = 0
      File.open(path, 'a') do |file|
        # A VTEX limita a paginação a VTEX_PAGINATION_LIMIT páginas por consulta.
        # Ao atingir o teto, reiniciamos a janela a partir do creationDate do
        # último pedido visto — mesmo janelamento que Vtex::Sync::Orders usa.
        loop do
          page = Vtex::Api::Page.paginate(
            api_client: api_client, client_method: :list_orders,
            method_args: { creation_date_range: from..to,
                           params: { orderBy: 'creationDate,asc', per_page: 100 } }
          )

          last = nil
          while page.next? && !page.limit_reached?
            orders = page.next['list']
            orders.each do |order|
              file.puts(order['orderId'])
              collected += 1
            end
            file.flush

            last = orders.last || last
            File.write(checkpoint_path, last['creationDate']) if last
          end

          break unless page.limit_reached? && last

          from = last['creationDate'].in_time_zone + 1.second
        end
      end

      puts "orderId coletados: #{collected} (arquivo: #{path})"
    end

    desc 'Zera as tabelas vtex_* e versions, reiniciando o auto_increment (ENV: CONFIRM=yes)'
    task reset: :environment do
      unless ENV['CONFIRM'] == 'yes'
        abort 'Operação destrutiva: zera todas as tabelas vtex_* e versions. Reexecute com CONFIRM=yes para confirmar.'
      end

      connection = ActiveRecord::Base.connection
      # As tabelas vtex_* são todas derivadas de pedido (inclusive vtex_cities/
      # states/countries, recriadas no sync do endereço). As de referência
      # geográfica são as ibge_*, que NÃO tocamos. TRUNCATE já reinicia o
      # AUTO_INCREMENT; desligamos a checagem de FK por causa das constraints.
      tables = connection.tables.select { |table| table.start_with?('vtex_') } + ['versions']
      begin
        connection.execute('SET FOREIGN_KEY_CHECKS = 0')
        tables.each { |table| connection.truncate(table) }
      ensure
        connection.execute('SET FOREIGN_KEY_CHECKS = 1')
      end

      puts "Tabelas zeradas (auto_increment reiniciado): #{tables.join(', ')}"
    end

    desc 'Enfileira jobs de sync a partir do arquivo de ids (ENV: file, limit, batch_size, batch_interval)'
    task enqueue: :environment do
      path = ENV['file'].presence || Rails.root.join('tmp/order_ids.txt').to_s
      abort "Arquivo de ids não encontrado: #{path}" unless File.exist?(path)

      batch_size = (ENV['batch_size'].presence || 100).to_i
      batch_interval = (ENV['batch_interval'].presence || 60).to_i.seconds
      raise ArgumentError, 'batch_size deve ser positivo' unless batch_size.positive?

      order_codes = File.readlines(path).map(&:strip).reject(&:empty?).uniq
      order_codes = order_codes.first(ENV['limit'].to_i) if ENV['limit'].to_i.positive?

      # Mesma estratégia de ondas escalonadas do Vtex::Orders::ResyncEnqueuer:
      # cada onda roda batch_interval depois da anterior para não estourar o
      # rate limit da VTEX. Se já há cooldown ativo, a 1ª onda já nasce adiada.
      initial_wait = ApiCooldown.retry_after_seconds(Vtex::Api::Client::COOLDOWN_KEY).seconds

      order_codes.each_with_index do |order_code, index|
        wait = initial_wait + ((index / batch_size) * batch_interval)
        Vtex::Sync::OrderJob.set(priority: JobPriority::LOWEST, wait: wait).perform_later(order_code)
      end

      puts "Pedidos enfileirados: #{order_codes.size} (arquivo: #{path})"
    end
  end
end
