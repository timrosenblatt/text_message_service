# require 'dalli'
# options = { :namespace => "app_v1", :compress => true }
# dc = Dalli::Client.new('localhost:11211', options)
# dc.set('abc', 123)
# value = dc.get('abc')


class ChatController < ApplicationController
  def create
    # write to DB
    # write to memcache
  end
  
  def show
    # load from DB
  end
  
  def show_all
    # load from memcache
  end
end
