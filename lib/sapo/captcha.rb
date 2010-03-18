require File.join(File.dirname(__FILE__), '..', 'sapo.rb')
require 'fileutils'

module SAPO
  class Captcha
    attr_reader :id, :code, :msg, :file
        
    def self.get(*args)
      self.new(*args)
    end
    
    def initialize(*args)
      args = Hash[*args]
      args[:mode]   ||= ''
      args[:ttl]    ||= ''
      args[:length] ||= ''
      doc = SAPO::get_xml("Captcha/Get?mode=#{args[:mode]}&ttl=#{args[:ttl]}&length=#{args[:length]}")
      @id = doc.at('id').text
      @code = doc.at('code').text
      @msg = doc.at('msg').text
      @file = "captcha_#{rand(100000)}.png"
    end
    
    def show(*args)
      args = Hash[*args]
      args[:font] ||= ''
      args[:textcolor] ||= ''
      args[:background] ||= ''
      args[:size] ||= ''
      open(@file, "w") do |file|
        file << open("http://services.sapo.pt/Captcha/Show?id=#{@id}&font=#{args[:font]}&background=#{args[:background]}&textcolor=#{args[:textcolor]}&size=#{args[:size]}").read
        puts "File saved to #{@file}"
      end
    end
    
    def file=(name)
      return @file unless name.is_a?(String)
      if @file.nil?
        FileUtils.touch name
      else
        FileUtils.mv @file, name
      end
      @file = name
    end
  end
end