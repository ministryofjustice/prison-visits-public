#!/bin/bash

set -e

export RAILS_SERVE_STATIC_FILES=true
bundle exec rails s -b 0.0.0.0 -p 4000
