# renderのcron jobで毎時8分にレコードを取得する処理
set -e

bundle exec rake amedas:import