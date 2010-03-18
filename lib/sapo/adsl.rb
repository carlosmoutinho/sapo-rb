require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module ADSL
    def self.has_coverage?(phone_number)
      # The method returns the root itself. The text can only be true or false.
      eval SAPO::get_xml("ADSL/HasCoverage?telephoneNumber=#{phone_number}").text
    end
  end
end