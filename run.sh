#!/bin/bash
export RAILS_ENV=production
bin/rails server -d --binding 0.0.0.0
tail -f /usr/src/app/log/logstash_production.json
