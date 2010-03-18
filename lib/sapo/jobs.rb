require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Jobs
    class Offer < Sapo::Base
      attr_reader :title, :link, :region, :pub_date, :description
      
      
      def self.find(*args)
        # Use '+' to separte query words. Example: 'note+leave' instead of 'note leave'
        # TODO: Find the perPage parameter to pass. Actually it always returns 10 results.
        args = Hash[*args]
        args[:query] ||= ''
        
        return [] if args[:query].empty? || args[:query] =~ /\s+/
        doc = SAPO::get_xml("JobOffers/RSS/Search?q=#{args[:query]}")
         
        doc.css('item').map do |p|
          self.new( :title => p.at('title').text, :link => p.at('link').text,
                    :region => p.text.split("\n").last, :pub_date => p.at('pubDate').text,
                    :description => p.at('description').text
                  )
        end
      end
    end    
  end
end