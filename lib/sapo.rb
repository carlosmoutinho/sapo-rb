require 'rubygems'
require 'open-uri'
require 'uri'
require 'nokogiri'
require 'json'

module SAPO
  VERSION = '0.0.5'
  API_URL = 'http://services.sapo.pt/'
  
  def self.get_xml(call)
    # puts "[+] #{API_URL + URI.escape(call)}"
    Nokogiri::XML(open( API_URL + URI.escape(call) )).root
  end

  def self.get_json(call)
    # puts "[+] #{API_URL + URI.escape(call)}"
    JSON.parse(open( API_URL + URI.escape(call) ).read)
  end
  
  class Base 
    def self.new(*args)
      super
    rescue Exception => exc
      puts "Ooopss. Something went wrong: #{exc.inspect}"
      return nil
    end
    
    def initialize(*args)
      args = Hash[*args]
      args.each { |k,v| eval("@#{k} = v.to_s") }
    end
  end
end