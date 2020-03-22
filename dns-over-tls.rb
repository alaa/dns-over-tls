#!/usr/bin/env ruby

require 'rubydns'
require 'logger'

class DNSProxy
  IN = Resolv::DNS::Resource::IN

  INTERFACES = [
    [:udp, '::', 53],
    [:tcp, '::', 53],
  ].freeze

  def startup
    $stderr.sync = true

    RubyDNS.run_server(INTERFACES) do
      on(:start) do
        @logger.level = Logger::DEBUG
        @logger.info "Starting DoT DNS over TLS ..."
      end

      match(/.+/, IN::A) do |tx, domain|
        response = KDIG.lookup(domain)
        response.lines.each do |addr|
            tx.respond!(addr.chomp!)
        end
      end

      otherwise do |tx|
        tx.fail!(:NXDomain)
      end
    end
  end

  class KDIG
    class << self
      def lookup(domain)
        `kdig @1.1.1.1 +tcp -p 853 +tls-ca +tls-host=cloudflare-dns.com +short #{domain} | grep '^[.0-9]*$'`
      end
    end
  end
end

proxy = DNSProxy.new
proxy.startup
