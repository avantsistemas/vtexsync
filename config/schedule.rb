# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :monitored_rake, 'cd :path && :environment_variable=:environment ' \
                          ':bundle_command rake :task --silent :output ' \
                          '&& curl https://api.honeybadger.io/v1/check_in/:honeybadger_check_in_id &> /dev/null'

set :path, ENV['PWD'] || Dir.pwd

# O cron roda em shell de login não-interativo (bash -l -c), que não ativa o
# mise. Colocamos os shims do mise no PATH para resolver ruby/bundle, igual ao
# que o systemd faz no serviço do Puma.
set :bundle_command,
    'PATH="/home/vtexsync/.local/share/mise/shims:$PATH" bundle exec'
# set :output, 'log/cron.log'

every 1.day, at: '2am' do
  monitored_rake 'vtex:sync_2_days_ago', honeybadger_check_in_id: 'KlI3yM'
end

# Enriquecimento de catálogo: drena diariamente os produtos pendentes
# (creation_date nulo) — tipicamente os recém-criados pelo sync de pedido, que
# nascem sem os atributos de catálogo (kit, ativo, data de criação).
# Para monitorar no Honeybadger, troque por monitored_rake com um check_in_id.
every 1.day, at: '3am' do
  rake 'vtex:enrich_products'
end

# Refresh completo semanal: reprocessa todo o catálogo (all=true) para capturar
# mudanças que possam ter ocorrido na VTEX (ex: IsActive/IsKit) após o produto
# já ter sido enriquecido.
every :sunday, at: '4am' do
  rake 'vtex:enrich_products all=true'
end
