require 'dalli'

module HotStorage
  def self.connection
    options = { :namespace => MEMCACHE_NAMESPACE, :compress => true }
    @@connection ||= Dalli::Client.new("#{MEMCACHE_HOST}:#{MEMCACHE_PORT}", 
                       options)
  end

  # There's a theoretical issue here, where the value could repeatedly be
  # appended until it overflows the size that the value can hold, without ever
  # being expired or read and deleted
  def self.store_message(message)
    connection.set(message.id, 
      MessagePresenter.new(message).as_json, 
      message.timeout)
    
    result = connection.cas(message.username) do |value|
      "#{value}|#{message.id}"
    end 
    if result.nil?
      connection.set(message.username, message.id)
    elsif !result # someone else modified the value before we got there
      connection.append(message.username, "|#{message.id}")
    end
    
    # Keeping the message index 
    connection.touch(message.username, message.timeout)
  end
  
  # No risk of race condition since the delete will only occur if the index
  # is unchanged between read and delete. It's plausible that another process
  # could read the index a second time before both are deleted, resulting in a
  # message being returned more than one time.
  def self.get_messages_for(username)
    messages_index = ''
    
    # This may return a false if it was unable to do the update. TODO add retry
    connection.cas(username) do |value|
      messages_index = value
      '' # replace the index with a blank value
    end
    
    all_ids = messages_index.split('|').compact

    all_messages = []
    connection.get_multi(*all_ids) do |key, value|
      all_messages << value
    end
    
    # Not really necessary since index has been destroyed, but this
    # handles the case where a message timeout was set to a huge value
    all_ids.each do |id|
      connection.delete(id)
    end
    
    all_messages
  end
end