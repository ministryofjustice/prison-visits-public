workers 4
thread_pool_size = ENV.fetch('RAILS_MAX_THREADS') { 5 }
threads thread_pool_size, thread_pool_size
preload_app!

after_worker_boot do
  require 'prometheus_exporter/instrumentation'
  PrometheusExporter::Instrumentation::Puma.start
  PrometheusExporter::Instrumentation::Process.start(type: 'web')
end
