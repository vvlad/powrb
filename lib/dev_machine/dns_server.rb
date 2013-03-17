require "rubydns"
module DevMachine::DNSServer extend self

  attr_accessor :timeout
  attr_accessor :thread
  Name = Resolv::DNS::Name
  IN = Resolv::DNS::Resource::IN
  UPSTREAM = RubyDNS::Resolver.new([[:udp, "8.8.8.8", 53], [:tcp, "8.8.8.8", 53]])


  def run
    @server ||= begin

      server = RubyDNS::Server.new do
        match(/\.dev$/, IN::A) do |_host, transaction|
          transaction.respond!("127.0.0.1")
        end

        otherwise do |transaction|
          transaction.passthrough!(UPSTREAM)
        end
      end

      EventMachine.run do

        server.fire(:setup)
        EventMachine.open_datagram_socket('127.0.0.1', 53533, RubyDNS::UDPHandler, server)

        server.fire(:start)
        server.logger.info "Server strated on udp://127.0.0.1:53533/"

      end

    end
  end



end
