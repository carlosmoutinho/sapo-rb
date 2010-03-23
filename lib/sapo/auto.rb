require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Auto
    class Car < SAPO::Base
      def self.create(url, root)
        SAPO::Base.get_xml(url).css(root).map do |doc|
          new :title => doc.at('title'), :link => doc.at('link'),
              :category => doc.at('category'), :image => doc.at('enclosure')['url'],
              :pub_date => doc.at('pubDate'), :comments => doc.at('comments')
        end
      rescue Exception => exc
        warn exc
        nil
      end
      
      private_class_method :new, :create
      
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
        puts "#{call}&sort=#{args[:sort]}"
        create("#{call}&sort=#{args[:sort]}", 'item')
      end
    end
  end
end