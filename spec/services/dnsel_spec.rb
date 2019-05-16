#require File.join(File.dirname(__FILE__), 'spec_helper')

require_relative "../../lib/tor"

describe Tor::DNSEL do
  before :all do
    $VERBOSE = nil # silence 'warning: already initialized constant' notices
    Resolv::DNS::Config::InitialTimeout = (ENV['TIMEOUT'] || 0.1).to_f
  end

  describe "Tor::DNSEL.include?" do
    it "returns true for exit nodes" do
      expect(Tor::DNSEL.include?('185.220.101.21')).to be_truthy
    end

    it "returns false for non-exit nodes" do
      expect(Tor::DNSEL.include?('1.2.3.4')).to be_falsey
    end

    it "returns nil on DNS timeouts" do
      begin
        Tor::DNSEL::RESOLVER = Resolv::DNS.new
        class << Tor::DNSEL::RESOLVER
          def each_address(host, &block)
            raise Resolv::ResolvTimeout
          end
        end
        expect(Tor::DNSEL.include?('1.2.3.4')).to be_nil
      ensure
        Tor::DNSEL::RESOLVER = Resolv::DefaultResolver
      end
    end
  end

  describe "Tor::DNSEL.query" do
    it "returns '127.0.0.2' for exit nodes" do
      expect Tor::DNSEL.query('185.220.101.21') == '127.0.0.2'
    end

    it "raises ResolvError for non-exit nodes" do
      expect(lambda { Tor::DNSEL.query('1.2.3.4') }).to raise_error(Resolv::ResolvError)
    end
  end

  describe "Tor::DNSEL.dnsname without options" do
    it "returns the correct DNS name" do
      expect Tor::DNSEL.dnsname('1.2.3.4') == '4.3.2.1.53.8.8.8.8.ip-port.exitlist.torproject.org'
    end
  end

  describe "Tor::DNSEL.dnsname with a target port" do
    it "returns the correct DNS name" do
      expect Tor::DNSEL.dnsname('1.2.3.4', :port => 25) == '4.3.2.1.25.8.8.8.8.ip-port.exitlist.torproject.org'
    end
  end

  describe "Tor::DNSEL.dnsname with a target IP address" do
    it "returns the correct DNS name" do
      expect Tor::DNSEL.dnsname('1.2.3.4', :addr => '8.8.4.4') == '4.3.2.1.53.4.4.8.8.ip-port.exitlist.torproject.org'
    end
  end

  describe "Tor::DNSEL.dnsname with a target IP address and port" do
    it "returns the correct DNS name" do
      expect Tor::DNSEL.dnsname('1.2.3.4', :addr => '8.8.4.4', :port => 25) == '4.3.2.1.25.4.4.8.8.ip-port.exitlist.torproject.org'
    end
  end

  describe "Tor::DNSEL.getaddress" do
    it "resolves IPv4 addresses" do
      expect Tor::DNSEL.getaddress('127.0.0.1') == '127.0.0.1'
      expect Tor::DNSEL.getaddress(IPAddr.new('127.0.0.1')) == '127.0.0.1'
    end

    it "resolves local hostnames" do
      expect Tor::DNSEL.getaddress('localhost') == '127.0.0.1'
    end

    it "resolves public hostnames" do
      expect(Tor::DNSEL.getaddress('google.com')).to match(Resolv::IPv4::Regex)
    end

    it "raises ArgumentError for IPv6 addresses" do
      expect(lambda { Tor::DNSEL.getaddress('::1') }).to raise_error(ArgumentError)
      expect(lambda { Tor::DNSEL.getaddress(IPAddr.new('::1')) }).to raise_error(ArgumentError)
    end

    it "raises ResolvError for nonexistent hostnames" do
      expect(lambda { Tor::DNSEL.getaddress('foo.example.org') }).to raise_error(Resolv::ResolvError)
    end
  end
end
