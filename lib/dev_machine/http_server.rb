require 'socket'
require 'thin'
require 'pathname'
require 'pp'
require 'securerandom'
require 'uri'

module DevMachine::HTTPServer extend self

  attr_accessor :root
  self.root = Pathname("#{ENV["HOME"]}/.dev/")

  autoload :Router, "dev_machine/http_server/router"

  def run
    root.mkpath
    uri = URI.parse("tcp://127.0.0.1:20080")
    app = ::DevMachine::Application::Router.new(root)
    server = Thin::Server.new(uri.host, uri.port, {})
    server.config
    server.app = app
    server.threaded= false

    ssl_uri = URI.parse("tcp://127.0.0.1:20443")
    ssl = Thin::Server.new(ssl_uri.host, ssl_uri.port, {})
    ssl.app = app
    ssl.ssl = true
    ssl.ssl_options = {
      :private_key_file => File.expand_path("../../../ssl/keys/server.key",__FILE__),
      :cert_chain_file => File.expand_path("../../../ssl/certs/server.cert",__FILE__),
      :verify_peer => @options[:ssl_verify]
    }

    EventMachine.run do
      server.start
      ssl.start
    end

  end


end
