require 'rubygems'
require 'open-uri'
require 'uri'
require 'nokogiri'
require 'json'
require 'ostruct'

module SAPO
  VERSION = '0.0.5'
  API_URL = 'http://services.sapo.pt/'
  
  class Base
    
    def self.get_xml(call)
      # puts "[+] #{API_URL + URI.escape(call)}"
      Nokogiri::XML(open( API_URL + URI.escape(call) )).root
    end

    def self.get_json(call)
      # puts "[+] #{API_URL + URI.escape(call)}"
      JSON.parse(open( API_URL + URI.escape(call) ).read)
    end
    
    def self.new(*args)
      super
    rescue Exception => exc
      puts "Ooopss. Something went wrong: #{exc.inspect}"
      return nil
    end
    
    def initialize(*args)
      args = Hash[*args]
      args.each do |k,v|
        if v.is_a?(Hash)
          eval("@#{k} = OpenStruct.new")
          v.each { |k_, v_| eval("@#{k}.#{k_} = v_") }
        else
          instance_variable_set("@#{k}", v)
        end
      end
    end
  end
end