require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Auto
    class Car
      attr_reader :title, :link, :category, :image, :pub_date, :comments
      
      def initialize(*params)
        params = Hash[*params]
        params.each { |k,v| eval "@#{k} = v.to_s" }
      end
      
      def self.find(*params)
        params = Hash[*params]
        params[:brand] ||= ''
        params[:model] ||= ''
        params[:sort]  ||= 'Price+desc'
        
        return [] if params[:brand].empty? && params[:model].empty?
        
        call = "Auto/RSS?q="
        arg_count = 0
        unless params[:brand].empty?
          call << "Brand:#{params[:brand]}"
          arg_count = 1
        end
        call << '+' if arg_count == 1
        call << "Model:#{params[:model]}" unless params[:model].empty?
        
        doc = SAPO::get_xml("#{call}&sort=#{params[:sort]}")
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