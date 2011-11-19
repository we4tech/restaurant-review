require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
ENV['DISPLAY'] ||= ":99"
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
