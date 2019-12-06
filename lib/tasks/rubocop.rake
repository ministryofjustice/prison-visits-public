if Gem.loaded_specs.key?('rubocop')
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  task(default: :environment).prerequisites << task(rubocop: :environment)
end
