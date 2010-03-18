require File.join(File.dirname(__FILE__), '..', 'sapo.rb')
require 'open-uri'
require 'json'

module SAPO
  module Photos
    class Photo
      attr_reader :title, :description, :link, :pub_date, :source
      
      def initialize(*params)
        params = Hash[*params]
        params.each { |k,v| eval "@#{k} = v.to_s" }
      end
    
      def self.find(*params)
        params = Hash[*params]
        params[:user] ||= ''
        params[:tag]  ||= ''

        return [] if params[:user].empty? && params[:tag].empty?
        doc = SAPO::get_xml("Photos/RSS?u=#{params[:user]}&tag=#{params[:tag]}")      
        
        doc.css('item').map do |p|
          self.new( :title => p.at('title').text, :source => p.at('fotoURL').text,
                    :description => p.at('description').text, :pub_date => p.at('pubDate').text,
                    :link => p.at('link').text
                  )
        end
      end
    end
  end
end