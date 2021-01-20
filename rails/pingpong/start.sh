#!/bin/sh
rm -rf tmp/pids/server.pid
rails db:migrate RAILS_ENV=development
rails server -b 0.0.0.0
