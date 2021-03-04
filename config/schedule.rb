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

set :bundle_command, "#{ENV['HOME']}/.rbenv/shims/bundle exec"
set :path, "#{ENV['HOME']}/vtexsync"
set :output, 'log/cron.log'

every 1.day, at: '2:00' do
  rake 'vtex:sync_1_week_ago'
end

every 1.week, at: '4:00 am' do
  rake 'vtex:sync_1_month_ago'
end
