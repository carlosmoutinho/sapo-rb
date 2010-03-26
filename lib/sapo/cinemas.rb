require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Cinemas
    
    class Theater < SAPO::Base
      def self.create(data, root)
        data = data.is_a?(String) ? SAPO::Base.get_xml(data) : data
        data.css(root).map do |doc|
          new :id => doc.at('Id'), :name => doc.at('Name'),
              :url => doc.at('URL'), :ticket_office_url => doc.at('TicketOfficeURL'),
              :phone => doc.at('Phone'), :country => doc.at('Country').children.last,
              :district => doc.at('District').children.last,
              :municipality => doc.at('Municipality').children.last,
              :latitude => doc.at('Latitude'), :longitude  => doc.at('Longitude'),
              :address => doc.at('Address'),
              :zip_code_prefix => doc.at('ZipCode'), :zip_code_sufix => doc.at('ZipCodeSufix'),
              :create_date => doc.at('CreateDate'), :doc => doc
        end
      end
      private_class_method :new, :create
          
      def self.find(*args)
        args = Hash[*args]
        args[:id] = args[:id].to_s
        return [] if args[:id].empty?
        create("Cinema/GetTheaterById?Id=#{args[:id]}&IncludeShowTimes=true", 'GetTheaterByIdResult')
      end
      
      def movies
        @movies ||= Movie.create(doc, 'MovieShowTimesList MovieShowTimes')
      end
    end
    
    class Movie < SAPO::Base      
      def self.create(data, root)
        data = data.is_a?(String) ? SAPO::Base.get_xml(data) : data
        data.css(root).map do |doc|
        new :id => doc.at('Id'), :title => doc.at('Title'), :year => doc.at('Year'),
             :country => doc.css('ProductionCountries Country').children.last,
             :runtime => doc.at('Runtime'), :synopsis => doc.at('Synopsis'),
             :release => { :country => doc.css('Release Country').children.last,
                           :title => doc.css('Release Title'),
                           :distributor => doc.css('Release Distributor'),
                           :date => doc.css('Release ReleaseDate'),
                           :rating => doc.css('Release Rating Name'),
                           :authority => doc.css('Release Authority Name')
                         },
             :doc => doc
        end
      end
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
          create("Cinema/GetMovieById?Id=#{args[:id]}", 'GetMovieByIdResult')
        else
          create("Cinema/GetMovies?Year=#{args[:year]}#{args[:genres].to_s}&PageNumber=#{args[:page]}&RecordsPerPage=#{args[:per_page]}", 'Movie')
        end
      rescue Exception => exc
        warn "Something went wrong: #{exc}"
        return nil
      end
      
      def contributors(role=nil)
        @contributors ||= Contributor.create(doc, 'Contributors Contributor')
        unless role.nil?
          @contributors.select do |c|
            if role.is_a?(Role)
              c.roles.select { |r| r.id == role.id && r.name == role.name }.size > 0
            elsif role.is_a?(String)
              c.roles.select { |r| r.name.downcase.include?(role) }.size > 0
            else
              false
            end
          end
        else
          @contributors
        end
      end
      
      def media
        @media ||= Media.create(doc, 'Media MediaItem')      
      end
      
      def show_times
        @show_times ||= doc.css('TimeStart').map(&:text)
      end
      
      def genres
        @genres ||= doc.css('Genres Genre').map do |ge|
          OpenStruct.new({ :id => ge.at('Id').text, :name => ge.at('Name').text })
        end
      end
      
    end
    
    class Media < SAPO::Base
      def self.create(data, root)
        data = data.is_a?(String) ? SAPO::Base.get_xml(data) : data
        data.css(root).map do |doc|
          new :type => doc.at('Type'), :category => doc.at('Category'),
              :url => doc.at('URL'), :extension => doc.at('Extension'),
              :rand_name => doc.at('RandName'),
              :doc => doc
        end
      rescue Exception => exc
        warn exc
        nil
      end
      
      def thumbnails
        doc.css('Thumbnail').map do |t|
          OpenStruct.new({
            :name => t.at('Name').text, :url => t.at('URL').text,
            :width => t.at('Width').text, :height => t.at('Height').text
          })
        end
      end
      
    end
      
    
    class Contributor < SAPO::Base
      def self.create(data, root)
        data = data.is_a?(String) ? SAPO::Base.get_xml(data) : data
        data.css(root).map do |doc|
          new :id => doc.css('Person Id'),
              :name => doc.at('Person Name'),
              :doc => doc
        end
      rescue Exception => exc
        warn exc
        nil
      end
      
      private_class_method :new
      
      def self.find(*args)
        args = Hash[*args]
        args[:id] = args[:id].to_s
        
        create("Cinema/GetPersonById?Id=#{args[:id]}", 'GetPersonByIdResult')
      end
      
      def roles
        @roles ||= Role.create(doc, 'Role')
      end

    end
    
    class Role < SAPO::Base
      def self.create(data, root)
        data = data.is_a?(String) ? SAPO::Base.get_xml(data) : data
        data.css(root).map do |doc|
          new :id => doc.at('Id'),
              :name => doc.at('Name')
        end
      rescue Exception => exc
        warn exc
        nil
      end
      
      private_class_method :new
      
      def self.find(*args)
        args = Hash[*args]
        roles = self.all
        if !args.nil?
          return roles.select do |r|
            if args[:id] && args[:name]
              r.name.downcase.include?(args[:name].to_s.downcase) && r.id == args[:id].to_s
            elsif !args[:name] && args[:id]
              r.id == args[:id].to_s
            elsif !args[:id] && args[:name]
              r.name.downcase.include?(args[:name].to_s.downcase)
            else
              false
            end
          end
        else
          []
        end
      end
      
      def self.all
        doc = SAPO::Base.get_xml("Cinema/GetContributorRoles?RecordsPerPage=30")
        doc.at('ContributorRoles').children.map { |r| new(:id => r.children.first, :name => r.children.last) }
      end
    end
    
  end
end