require 'bundler'
require 'rspec/core/rake_task'

task :default => [:spec]
task :test => [:spec]

desc "run spec tests"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc "run the coffeescript compiler"
task :coffee do
  sh 'coffee -w -o public/js -c coffeescripts/*.coffee'
end
