require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Photos
    class Photo < SAPO::Base
      attr_reader :title, :description, :link, :pub_date, :source

      def self.find(*args)
        args = Hash[*args]
        args[:user] ||= ''
        args[:tag]  ||= ''

        return [] if args[:user].empty? && args[:tag].empty?
        doc = SAPO::get_xml("Photos/RSS?u=#{args[:user]}&tag=#{args[:tag]}")      
        
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