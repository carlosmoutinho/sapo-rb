require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Blogs
    class Post < SAPO::Base
      attr_reader :title, :link, :author, :pub_date, :description, :source    
      
      def self.find(*args)
        # Use '+' to separte query words. Example: 'note+leave' instead of 'note leave'
        # TODO: Find the perPage parameter to pass. Actually it always returns 10 results.
        args = Hash[*args]
        args[:query] ||= ''
        args[:limit] ||= ''
        return [] if args[:query].empty? || args[:query] =~ /\s+/
        doc = SAPO::get_xml("Blogs/RSS/Search?q=#{args[:query]}&limit=#{args[:limit]}")      
        doc.css('item').map do |p|
          self.new( :title => p.at('title').text, :link => p.at('link').text,
                    :author => p.at('author').text, :pub_date => p.at('pubDate').text,
                    :description => p.at('description').text, :source => p.at('source')['url']
                  )
        end
      end
    end
  end
end