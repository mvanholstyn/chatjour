require 'rubygems'
require 'spec'
require 'spec/story'

Dir[File.expand_path(File.dirname(__FILE__) + '/steps/*.rb')].each do |f|
  require f
end