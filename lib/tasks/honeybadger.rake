namespace :honeybadger do
  task enqueue_queue_health_check: :environment do
    check_in_id = 'xoI5vM'
    job_class = 'Honeybadger::QueueHealthCheckJob'

    if Delayed::Job.exists?(['handler LIKE ?', "%job_class: #{job_class}%"])
      puts "#{job_class} já está enfileirado — nada a fazer."
      next
    end

    Honeybadger::QueueHealthCheckJob.perform_later(check_in_id)
    puts "#{job_class} enfileirado com check-in #{check_in_id}."
  end
end
