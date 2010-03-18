require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Blogs
    class Post
      attr_reader :title, :link, :author, :pub_date, :description, :source    
      
      def initialize(*params)
        params = Hash[*params]
        params.each { |k,v| eval "@#{k} = v.to_s" }
      end
      
      def self.find(*params)
        # Use '+' to separte query words. Example: 'note+leave' instead of 'note leave'
        # TODO: Find the perPage parameter to pass. Actually it always returns 10 results.
        params = Hash[*params]
        params[:query] ||= ''
        params[:limit] ||= ''
        return [] if params[:query].empty? || params[:query] =~ /\s+/
        doc = SAPO::get_xml("Blogs/RSS/Search?q=#{params[:query]}&limit=#{params[:limit]}")      
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