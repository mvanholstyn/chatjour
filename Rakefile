require 'rake'
require 'spec/rake/spectask'

task :default => :spec

desc "Run all specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec', '--exclude', 'rcov', '--exclude', 'dnssd', '--exclude', 'runner']
end
