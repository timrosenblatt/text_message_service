# TODO add validations in model
class Message < ActiveRecord::Base
  before_save :set_expiration_date
  
  attr_accessor :timeout
  
  def set_expiration_date
    if timeout.nil?
      self.timeout = Message.default_timeout.seconds
    end
      
    self.expiration_date = Time.now + timeout
  end
  
  def self.default_timeout
    60
  end
end
