namespace :services do
  services = %w[puma delayed_job]

  desc 'Verifica o status dos serviços'
  task :status do
    on roles(:app) do
      services.each do |service|
        execute "sudo systemctl status #{service}", raise_on_non_zero_exit: false
      end
    end
  end

  desc 'Inicia os serviços'
  task :start do
    on roles(:app) do
      services.each { |service| execute "sudo systemctl start #{service}" }
    end
  end

  desc 'Para os serviços'
  task :stop do
    on roles(:app) do
      services.each { |service| execute "sudo systemctl stop #{service}" }
    end
  end

  desc 'Reinicia os serviços'
  task :restart do
    on roles(:app) do
      services.each { |service| execute "sudo systemctl restart #{service}" }
    end
  end
end
