require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Photos
    class Photo < SAPO::Base
       def self.create(data, root)
          data = data.is_a?(String) ? SAPO::Base.get_xml(data) : data
          data.css(root).map do |doc|
          new :title => doc.at('title'), :source => doc.at('fotoURL'),
              :description => doc.at('description'), :pub_date => doc.at('pubDate'),
              :link => doc.at('link'),
              :doc => doc
              
        end
      rescue Exception => exc
        warn exc
        nil
      end
      
      def self.find(*args)
        args = Hash[*args]
        args[:user] ||= ''
        args[:tag]  ||= ''

        return [] if args[:user].empty? && args[:tag].empty?
        create("Photos/RSS?u=#{args[:user]}&tag=#{args[:tag]}", 'item')
      end
    end
  end
end