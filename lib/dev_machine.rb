require "dev_machine/version"
$: << File.expand_path("../nack/lib",__FILE__)
module DevMachine
  autoload :DNSServer, "dev_machine/dns_server"
  autoload :HTTPServer, "dev_machine/http_server"
  autoload :Application, "dev_machine/application"
end
