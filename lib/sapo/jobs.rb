require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Jobs
    class Offer < SAPO::Base
       def self.create(data, root)
          data = data.is_a?(String) ? SAPO::Base.get_xml(data) : data
          data.css(root).map do |doc|
          new :title => doc.at('title'), :link => doc.at('link'),
              :region => doc.text.split("\n").last, :pub_date => doc.at('pubDate'),
              :description => doc.at('description'),
              :doc => doc
              
        end
      rescue Exception => exc
        warn exc
        nil
      end
      
      private_class_method :new, :create
      
      def self.find(*args)
        # Use '+' to separte query words. Example: 'note+leave' instead of 'note leave'
        # TODO: Find the perPage parameter to pass. Actually it always returns 10 results.
        args = Hash[*args]
        args[:query] ||= ''
        
        return [] if args[:query].empty? || args[:query] =~ /\s+/
        create("JobOffers/RSS/Search?q=#{args[:query]}", 'item')
      end
    end    
  end
end