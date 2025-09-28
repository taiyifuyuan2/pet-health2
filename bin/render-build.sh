#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
bundle exec rails db:seed

# ActiveStorageの設定確認
echo "ActiveStorage configuration check..."
bundle exec rails runner "puts 'ActiveStorage configured: ' + ActiveStorage::Blob.table_name"
