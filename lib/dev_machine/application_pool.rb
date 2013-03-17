require 'dev_machine/application'
class DevMachine::ApplicationPool

  def initialize(rackup,pool_size=3)
    @rackup = rackup
    @pool_size = pool_size
    @apps = pool_size.times.map { DevMachine::Application.new(rackup) }
    @enum = @apps.to_enum
  end


  def call(env)
    app = @enum.next
    app.call(env)
  rescue StopIteration
    @enum = @apps.to_enum
    retry
  end


end
