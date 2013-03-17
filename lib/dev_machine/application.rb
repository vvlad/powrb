require 'socket'
require 'json'
require 'nack/netstring'

class DevMachine::Application


  autoload :Router, "dev_machine/application/router"

  attr :rackup, :worker, :path
  def initialize(rackup)
    @rackup = rackup
    @mutex = Mutex.new
    @path = Pathname(rackup).dirname
  end

  def call(env)

    input = env["rack.input"]
    env = env.reject { |k,v| ["async.callback","async.close","rack.input", "rack.errors"].include? k}
    socket = worker
    socket << Nack::NetString.encode(env.to_json)
    socket << Nack::NetString.encode(input.read)
    socket.close_write

    body = []
    status = nil
    headers = nil
    loop do
      Nack::NetString.read(socket) do |buffer|
        if status.nil?
          status = buffer
        elsif headers.nil?
          headers = JSON.parse(buffer)
        else
          body << buffer
        end
      end
      break if socket.eof?
    end

    [status.to_i, headers, body]
  end

  def worker
    unless worker?
      @socket_path = "/tmp/nack.#{$$}.#{Time.now.to_i}.#{rand(Time.now.to_f)}.socket"
      ENV["RUBYLIB"] ||= ["#{File.expand_path("../../nack/lib",__FILE__)}", ENV["RUBYLIB"]].compact.join(":")
      cmd = "#{File.expand_path("../../nack/bin",__FILE__)}/nack_worker #{@rackup} #{@socket_path}"
      @pid = spawn cmd, chdir: @path

      begin
        @socket = UNIXSocket.new(@socket_path)
      rescue => e
        sleep 0.2
        retry
      end

      pid = @socket.readline.to_i

      puts "Started worker with pid #{@pid}"
    end
    UNIXSocket.new(@socket_path)
  end

  def worker?
    !@socket.nil?
  end

end

