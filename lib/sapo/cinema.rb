require File.join(File.dirname(__FILE__), '..', 'sapo.rb')
require 'ostruct'

module SAPO
  module Cinemas
    
    class Theater < SAPO::Base
      attr_reader :id, :name, :url, :ticket_url, :phone, :country, :district,
                  :municipality, :latitude, :longitude, :address, :zipcode
    end
    
    class Genre < SAPO::Base
      attr_reader :id, :name
    end
    
    class Movie < SAPO::Base
      attr_reader :id, :title, :year, :country, :runtime, :synopsis, :genres, :release
      private_class_method :new 
      
      def self.find(*args)
        args = Hash[*args]
        args[:id] = args[:id].to_s
        args[:per_page] ||= args[:id].empty? ? '50' : '1'
        args[:page] ||= '1'
        args[:genres] = [args[:genres]].flatten.compact
        unless args[:genres].size == 0
          args[:genres] = '&GenreIds=' + args[:genres].map { |g| g.id.to_s }.join(',')
        end
        args[:year] ||= Time.now.year.to_s
        
        unless args[:id].empty?
          doc = SAPO::Base.get_xml("Cinema/GetMovieById?Id=#{args[:id]}")
        else
          doc = SAPO::Base.get_xml("Cinema/GetMovies?Year=#{args[:year]}#{args[:genres].to_s}&PageNumber=#{args[:page]}&RecordsPerPage=#{args[:per_page]}")
        end
        
        results = doc.css(args[:id].empty? ? 'Movie' : 'GetMovieByIdResult').to_a.map do |g|
          new( :id => g.at('Id').text, :title => g.at('Title').text, :year => g.at('Year').text,
               :country => g.css('ProductionCountries Country').children.last.text,
               :runtime => g.at('Runtime').text, :synopsis => g.at('Synopsis').text,
               :genres => g.css('Genres Genre').map { |ge| Genre.new( :id => ge.at('Id').text, :name => ge.at('Name').text) },
               :release => { :country => g.css('Release Country').children.last.text,
                             :title => g.css('Release Title').text,
                             :distributor => g.css('Release Distributor').text,
                             :date => g.css('Release ReleaseDate').text,
                             :rating => g.css('Release Rating Name').text,
                             :authority => g.css('Release Authority Name').text
                            }
              )
        end
        results.size == 1 ? results.first : results
      rescue Exception => exc
        puts "Something went wrong: #{exc}"
        return nil
      end
      
    end
  
    class Person < SAPO::Base
      attr_reader :id, :name
      private_class_method :new
      
      def self.find(*args)
        args = Hash[*args]
        args[:id] = args[:id].to_s
        doc = SAPO::Base.get_xml("Cinema/GetPersonById?Id=#{args[:id]}")
        new( :id => doc.at('Id').text,
             :name => doc.at('Name').text
           )
      rescue Exception => exc
        puts "Something went wrong: #{exc}"
        return nil
      end

    end
    
    class Role
      attr_reader :id, :name
      private_class_method :new
      
      def self.find(*args)
        args = Hash[*args]
        roles = self.all
        if !args.nil?
          return roles.select do |r|
            if args[:id] && args[:name]
              r[:name].downcase.include?(args[:name].to_s.downcase) && r[:id] == args[:id].to_s
            elsif !args[:name] && args[:id]
              r[:id] == args[:id].to_s
            elsif !args[:id] && args[:name]
              r[:name].downcase.include?(args[:name].to_s.downcase)
            else
              false
            end
          end
        else
          []
        end
      end
      
      def self.all
        doc = get_xml("Cinema/GetContributorRoles?RecordsPerPage=30")
        doc.at('ContributorRoles').children.map { |r| {:id => r.children.first.text, :name => r.children.last.text} }
      end
    end
    
  end
end