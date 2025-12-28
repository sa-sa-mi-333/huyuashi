# 公式ドキュメントを元に追加

set -o errexit

bundle install
# プリコンパイル前にtailwindcssのビルド
bin/rails tailwindcss:build
bin/rails assets:precompile
bin/rails assets:clean