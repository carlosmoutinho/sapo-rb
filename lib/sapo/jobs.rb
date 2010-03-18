require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Jobs
    class Offer
      attr_accessor :title, :link, :region, :pub_date, :description
      
      def initialize(*params)
        params = Hash[*params]
        params.each { |k,v| eval "@#{k} = v.to_s" }
      end
      
      def self.find(*params)
        # Use '+' to separte query words. Example: 'note+leave' instead of 'note leave'
        # TODO: Find the perPage parameter to pass. Actually it always returns 10 results.
        params = Hash[*params]
        params[:query] ||= ''
        return [] if params[:query].empty? || params[:query] =~ /\s+/
        doc = SAPO::get_xml("JobOffers/RSS/Search?q=#{params[:query]}")      
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