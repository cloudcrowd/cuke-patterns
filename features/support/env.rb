$LOAD_PATH.push File.expand_path(File.join(File.dirname(__FILE__),'..','..','lib'))

require 'cuke-patterns'

class MyWorld
  # This method is here to ensure we test the proper binding for applied patterns.
  def assert_pony!
    :bray!
  end
end

World do
  MyWorld.new
end
