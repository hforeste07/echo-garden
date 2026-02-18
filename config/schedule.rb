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

set :environment, "production"
set :output, "log/cron.log"

every 1.year, at: '2:00 am' do
  runner "LocationsImportJob.perform_later"
  runner "PlantsImportJob.perform_later"
end

set :output, "log/cron.log"
env :PATH, ENV['PATH']

# Run every 6 minutes to use 10 requests/hour
every 6.minutes do
  rake "flora:import"
end
