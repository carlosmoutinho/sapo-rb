require 'rubygems'
require 'open-uri'
require 'uri'
require 'nokogiri'
require 'json'

module SAPO
  VERSION = '0.0.5'
  API_URL = 'http://services.sapo.pt/'
  
  def self.get_xml(call)
    Nokogiri::XML(open( API_URL + URI.escape(call) )).root
  end
  
  def self.get_json(call)
    JSON.parse(open( API_URL + URI.escape(call) ))
  end
end