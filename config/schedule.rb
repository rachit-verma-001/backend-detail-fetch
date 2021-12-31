# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :environment, "development"
set :output, "log/cron_log.log"
#
# Tz = "Asia/Kuala_Lumpur"
# case @environment

# when 'development'	
# 	every 1.minute do
# 	  rake "firefox_data:sync_job", environment: "development"
# 	end

# end


	every 2.hours do
	  rake "firefox_data:sync_job"
	end



#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
