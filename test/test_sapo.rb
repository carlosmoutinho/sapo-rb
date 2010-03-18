require File.join(File.dirname(__FILE__), '..', 'lib/sapo.rb')
require File.join(File.dirname(__FILE__), '..', 'lib/sapo/photos.rb')
require File.join(File.dirname(__FILE__), '..', 'lib/sapo/shopping.rb')

require "protest"

include SAPO::Photos
include SAPO::Shopping

Protest.context("A Photo") do
  setup do
    @photos = Photo.find(:tag => 'arcade', :user => 'celso')
    puts @photos.first.inspect
  end

  test "is not nil" do
    assert !@photos.nil?
  end
end

Protest.context('A Shopping') do
  setup do
    @listing = Listing.find(:query => 'almada') 
  end
  
  test "is not null" do
    assert !@listing.nil?
  end
end