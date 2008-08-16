require 'rubygems'
require 'spec'
require 'spec/story'
require 'stringio'

require File.expand_path(File.dirname(__FILE__) + '/../lib/chatjour')

Dir[File.expand_path(File.dirname(__FILE__) + '/steps/*.rb')].each do |f|
  require f
end