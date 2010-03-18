require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module AdWords
    class Ad
      attr_reader :title, :line1, :line2, :display_url, :ad_link_url

      def initialize(*params)
        params = Hash[*params]
        params.each { |k,v| eval "@#{k} = v.to_s" }
      end
      
      def self.find(*params)
        params = Hash[*params]
        params[:query] ||= ''
        return [] if params[:query].empty? || params[:query] =~ /\s+/
        doc = SAPO::get_xml("AdWords/JSON?q=#{params[:query]}&o=xml")
        doc.css('AdResults Result').to_a.map do |ad|
          self.new( :title => ad.at('Title').text, :line1 => ad.at('Line1').text,
                    :line2 => ad.at('Line2').text, :display_url => ad.at('DisplayURL').text,
                    :ad_link_url => ad.at('AdLinkURL').text
                  )
        end
      end
    end
  end
end