class Message < ActiveRecord::Base
  before_save :set_expiration_date
  after_create :put_in_hot_storage
  
  attr_accessor :timeout
  
  def set_expiration_date
    if timeout.nil?
      self.timeout = Message.default_timeout.seconds
    end
      
    self.expiration_date = Time.now + timeout
  end

  def put_in_hot_storage
    HotStorage.store_message(self)
  end
  
  def self.default_timeout
    60
  end
end
