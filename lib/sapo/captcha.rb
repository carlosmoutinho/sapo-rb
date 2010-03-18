require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  class Captcha
    attr_reader :id, :code, :msg
    
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
      params[:color] ||= ''
      params[:size] ||= ''
      rand_name = "captcha_#{rand(100000)}.png"
      open(rand_name, "w") do |file|
        file << open("http://services.sapo.pt/Captcha/Show?id=#{@id}&font=#{params[:font]}&color=#{params[:color]}&size=#{params[:size]}").read
        puts "File saved to #{rand_name}"
      end
    end
  
  end
end