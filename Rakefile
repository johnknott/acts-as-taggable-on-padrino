begin # Rspec 2.0
  require 'rspec/core/rake_task'

  desc 'Default: run specs'
  task :default => :spec  
  RSpec::Core::RakeTask.new do |t|
    t.pattern = "spec/**/*_spec.rb"
  end
  
  RSpec::Core::RakeTask.new('rcov') do |t|
    t.pattern = "spec/**/*_spec.rb"
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec']
  end

rescue LoadError
  puts "Rspec not available. Install it with: gem install rspec"  
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "acts-as-taggable-on-padrino"
    gemspec.summary = "ActsAsTaggableOnPadrino is a tagging plugin for Padrino that provides multiple tagging contexts on a single model."
    gemspec.description = "Padrino version of the popular Rails tagging plugin. With ActsAsTaggableOnPadrino, you could tag a single model on several contexts, such as skills, interests, and awards. It also provides other advanced functionality."
    gemspec.email = "john.knott@gmail.com"
    gemspec.homepage = "http://github.com/johnknott/acts-as-taggable-on-padrino"
    gemspec.authors = ["Michael Bleigh","John Knott"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
