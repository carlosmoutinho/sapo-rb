require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Auto
    class Car < SAPO::Base
      attr_reader :title, :link, :category, :image, :pub_date, :comments
      
      def self.find(*args)
        args = Hash[*args]
        args[:brand] ||= ''
        args[:model] ||= ''
        args[:sort]  ||= 'Price+desc'
        
        return [] if args[:brand].empty? && args[:model].empty?
        
        call = "Auto/RSS?q="
        arg_count = 0
        unless args[:brand].empty?
          call << "Brand:#{args[:brand]}"
          arg_count = 1
        end
        call << '+' if arg_count == 1
        call << "Model:#{args[:model]}" unless args[:model].empty?
        
        doc = SAPO::get_xml("#{call}&sort=#{args[:sort]}")
        doc.css('item').to_a.map do |a|
          self.new( :title => a.at('title').text, :link => a.at('link').text,
                    :category => a.at('category').text, :image => a.at('enclosure')['url'],
                    :pub_date => a.at('pubDate').text, :comments => a.at('comments').text
                  )
        end
      end
    end
  end
end