require File.join(File.dirname(__FILE__), '..', 'sapo.rb')
require 'fileutils'

module SAPO
  class Captcha
    attr_reader :id, :code, :msg, :file
    
    def self.get(*params)
      self.new(*params)
    end
    
    def initialize(*params)
      params = Hash[*params]
      params[:mode]   ||= ''
      params[:ttl]    ||= ''
      params[:length] ||= ''
      doc = SAPO::get_xml("Captcha/Get?mode=#{params[:mode]}&ttl=#{params[:ttl]}&length=#{params[:length]}")
      @id = doc.at('id').text
      @code = doc.at('code').text
      @msg = doc.at('msg').text
    end
    
    def show(*params)
      params = Hash[*params]
      params[:font] ||= ''
      params[:textcolor] ||= ''
      params[:background] ||= ''
      params[:size] ||= ''
      @file ||= "captcha_#{rand(100000)}.png"
      open(@file, "w") do |file|
        file << open("http://services.sapo.pt/Captcha/Show?id=#{@id}&font=#{params[:font]}&background=#{params[:background]}&textcolor=#{params[:textcolor]}&size=#{params[:size]}").read
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