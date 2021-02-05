namespace :procodile do
  desc 'Verifica o status dos processos do procodile'
  task :status do
    on roles(:app) do
      execute procodile_command 'status'
    end
  end

  desc 'Inicia os processos do procodile'
  task :start do
    on roles(:app) do
      execute "eval \"$($HOME/.rbenv/bin/rbenv init -)\" && #{procodile_command 'start'}"
    end
  end

  desc 'Reinicia os processos do procodile'
  task :restart do
    on roles(:app) do
      execute procodile_command 'restart'
    end
  end

  desc 'Para os processos do procodile e o supervisor'
  task :stop do
    on roles(:app) do
      execute procodile_command 'stop --stop-supervisor --wait'
    end
  end

  def procodile_command(command)
    "$HOME/.rbenv/shims/procodile #{command} --root #{fetch(:deploy_to)}/current"
  end
end
