# renderのcron jobで毎時8分にレコードを取得する処理
set -e

bundle exec rake amedas:import
bundle exec rake snow_depth:update_all
