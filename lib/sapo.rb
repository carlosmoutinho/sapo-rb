require 'rubygems'
require 'open-uri'
require 'uri'
require 'nokogiri'
require 'ostruct'

module SAPO
  VERSION = '0.0.5'
  API_URL = 'http://services.sapo.pt/'
  
  class Base
    
    def self.get_xml(call)
      # puts "[+] #{API_URL + URI.escape(call)}"
      Nokogiri::XML(open( API_URL + URI.escape(call) )).root
    end
    
    def initialize(*args)
      args = Hash[*args]
      args.each do |k,v|
        if v.is_a?(Hash)
          instance_variable_set("@#{k}", OpenStruct.new)
          v.each do |k_,v_|
            eval "@#{k}.#{k_} = v_.respond_to?(:text) ? v_.text : v_"
          end
        else
          instance_variable_set("@#{k}", v.respond_to?(:text) ? v.text : v)
        end
        self.class.__send__(:define_method, "#{k}") { eval("@#{k}") }
      end
    end
  end
end