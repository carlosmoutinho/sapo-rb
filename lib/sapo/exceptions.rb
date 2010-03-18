require File.join(File.dirname(__FILE__), '..', 'sapo.rb')

module SAPO
  module Exceptions
    class NilResponse < StandardError
      def to_s
        "Maybe some parameters were invalid?"
      end  
    end
  end
end