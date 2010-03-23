require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module AdWords
    class Ad < SAPO::Base      
      def self.create(url, root)
        SAPO::Base.get_xml(url).css(root).map do |doc|
          new :title => doc.at('Title'), :line1 => doc.at('Line1'),
              :line2 => doc.at('Line2'), :display_url => doc.at('DisplayURL'),
              :ad_link_url => doc.at('AdLinkURL')
        end
      rescue Exception => exc
        warn exc
        nil
      end
      
      private_class_method :new, :create
      
      def self.find(*args)
        args = Hash[*args]
        args[:query] ||= ''
        return [] if args[:query].empty? || args[:query] =~ /\s+/
        create("AdWords/JSON?q=#{args[:query]}&o=xml", 'AdResults Result')
      end
    end
  end
end