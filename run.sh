#!/bin/bash
bin/rails server -e production -d --binding 0.0.0.0
tail -f /usr/src/app/log/logstash_production.json
