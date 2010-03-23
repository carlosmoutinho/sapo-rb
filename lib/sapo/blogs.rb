require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Blogs
    class Post < SAPO::Base
      def self.create(url, root)
        SAPO::Base.get_xml(url).css(root).map do |doc|
          new :title => doc.at('title'), :link => doc.at('link'),
              :author => doc.at('author'), :pub_date => doc.at('pubDate'),
              :description => doc.at('description'), :source => doc.at('source')['url']
        end
      rescue Exception => exc
        warn exc
        nil
      end
      
      def self.find(*args)
        # Use '+' to separte query words. Example: 'note+leave' instead of 'note leave'
        # TODO: Find the perPage parameter to pass. Actually it always returns 10 results.
        args = Hash[*args]
        args[:query] ||= ''
        args[:limit] ||= ''
        return [] if args[:query].empty? || args[:query] =~ /\s+/
        create("Blogs/RSS/Search?q=#{args[:query]}&limit=#{args[:limit]}", 'item')
      end
    end
  end
end