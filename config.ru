# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

require 'rack/gc_tracer'

use Rack::GCTracerMiddleware, filename: 'log/gc.log'

run Rails.application
