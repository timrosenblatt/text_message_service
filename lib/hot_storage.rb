require 'dalli'

# this needs to be horizontally scalable -- all memcache methods must use CAS
module HotStorage
  
  def self.connection
    options = { :namespace => MEMCACHE_NAMESPACE, :compress => true }
    @@connection ||= Dalli::Client.new("#{MEMCACHE_HOST}:#{MEMCACHE_PORT}", 
                       options)
  end

  # There's a theoretical issue here, where the value could repeatedly be
  # appended until it overflows the size that the value can hold, without ever
  # being expired or read and deleted
  def self.store_message(message, timeout)
    connection.set(message.id, 
      MessagePresenter.new(message).as_json.to_json, 
      timeout)
    connection.append(message.username, "|#{message.id}")
    connection.touch(message.username, timeout)
  end
  
  # No risk of race condition since the delete will only occur if the index
  # is unchanged between read and delete. It's plausible that another process
  # could read the index a second time before it is deleted, resulting in a
  # message being returned more than one time.
  def self.get_messages_for(username)
    messages_index = ''
    
    connection.cas(username) do |value|
      messages_index = value
      ''
    end
    
    all_ids = messages_index.split('|').compact

    all_messages = connection.get_multi(*all_ids)
    
    # Not really necessary since index has been destroyed, but this
    # handles in case a message timeout was set to a huge value
    all_ids.each do |id|
      connection.delete(id)
    end
    
    all_messages
  end
end