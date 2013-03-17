require 'dev_machine/application_pool'
class DevMachine::Application::Router

  attr :root
  def initialize(root)
    @root = root
  end

  def call(env)
    host = env["SERVER_NAME"]
    if app = apps[host]
      app.call(env)
    else
      [404, { "Content-Type" => "text/html"}, ["Not Found"]]
    end
  end

  def apps
    @apps ||= load_apps
  end
  private

  def load_apps
    Dir[root.join("*/config.ru")].inject({}) do |apps,rackup|
      name = Pathname(rackup).dirname.basename
      host = "#{name}.dev"
      apps[host] = DevMachine::ApplicationPool.new(rackup)
      apps
    end

  end
end
