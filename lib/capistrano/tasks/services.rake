# frozen_string_literal: true

namespace :services do
  desc 'Verifica o status dos serviços'
  task :status do
    on roles(:app) do
      execute 'systemctl status puma delayed_job', raise_on_non_zero_exit: false
    end
  end

  desc 'Inicia os serviços'
  task :start do
    on roles(:app) do
      execute 'sudo systemctl start puma delayed_job'
    end
  end

  desc 'Para os serviços'
  task :stop do
    on roles(:app) do
      execute 'sudo systemctl stop puma delayed_job'
    end
  end

  desc 'Reinicia os serviços'
  task :restart do
    on roles(:app) do
      execute 'sudo systemctl restart puma delayed_job'
    end
  end
end
