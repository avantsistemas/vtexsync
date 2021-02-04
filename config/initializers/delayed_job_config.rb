# Delayed::Worker.sleep_delay = 60
Delayed::Worker.default_priority = 5
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.delay_jobs = !Rails.env.test?
# Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
