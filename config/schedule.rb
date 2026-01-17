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

# Rails.rootを使うための記載
require File.expand_path(File.dirname(__FILE__) + "/environment")

# cronを実行する環境変数の設定
ENV.each { |k, v| env(k, v) }
rails_env = ENV["RAILS_ENV"] || :development

# cronを実行する環境変数をセット
set :environment, rails_env

# cronのログの吐き出し場所
set :output, "#{Rails.root}/log/cron.log"

# 毎時8分に実行
every "8 * * * *" do
  rake "amedas:import && rake user_records:calculate_snow_depths"
end

# ログローテーション(毎日0時に実行)
every 1.day, at: "0:00 am" do
  command "mv log/cron.log log/cron.log.$(date +\\%Y\\%m\\%d) 2>&1"
end
