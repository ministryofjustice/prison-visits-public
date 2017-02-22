#!/bin/bash
bundle exec puma -b tcp://0.0.0.0:3000 -d
tail -f /usr/src/app/log/logstash_production.json
