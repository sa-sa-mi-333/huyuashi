# renderのcron jobで毎時8分にレコードを取得する処理
set -e

bundle exec rake amedas:import
bundle exec rake user_records:calculate_snow_depths