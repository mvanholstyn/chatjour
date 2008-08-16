require 'rubygems'
require 'spec'
require 'spec/story'
require 'open3'
require 'ostruct'

require File.expand_path(File.dirname(__FILE__) + '/../lib/chatjour')

Dir[File.expand_path(File.dirname(__FILE__) + '/steps/*.rb')].each do |f|
  require f
end