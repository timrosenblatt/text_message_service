require 'dalli'

module HotStorage
  def self.store_message(message)
    store_message_contents(message)
    update_unread_message_index(message)
  end
  
  # No risk of race condition since the delete will only occur if the index
  # is unchanged between read and delete. It's plausible that another process
  # could read the index a second time before both are deleted, resulting in a
  # message being returned more than one time.
  def self.get_messages_for(username)
    all_ids = fetch_and_clear_index!(username)
    all_messages = get_multiple_keys(all_ids)
    delete_multiple_keys(all_ids)
    
    all_messages
  end
  
  private
  
  def self.delete_multiple_keys(all_ids)
    all_ids.each do |id|
      connection.delete(id)
    end
  end
  
  def self.get_multiple_keys(all_ids)
    all_messages = []
    connection.get_multi(*all_ids) do |key, value|
      all_messages << value
    end
    all_messages
  end

  # By reading the index, it is destroyed, as a requirement of the system
  def self.fetch_and_clear_index!(username)
    messages_index = ''
    
    # If this .cas fails to set it, it's been modified by another process, and
    # the messages will be deleted later anyways, so the modification will 
    # mean that the un-deleted message will be returned ok
    connection.cas(username) do |value|
      messages_index = value
      '' # replace the index with a blank value
    end
    
    messages_index.split('|').compact
  end
  
  def self.store_message_contents(message)
    connection.set(message.id, 
      MessagePresenter.new(message).as_json, 
      message.timeout)
  end
  
  # It's possible that the index could be written to without being read and
  # flushed until it overflows the 1MB value size limit. This happens faster
  # the longer the system has been online. Monitoring would be helpful.
  # This happens around 150,000 messages, as tested by
  # all = [] ; (1..150000).each {|i| all << i } ; all.join('|').size
  def self.update_unread_message_index(message)
    result = connection.cas(message.username) do |value|
      "#{value}|#{message.id}"
    end 
    # There's a possible case where the index could have been modified or 
    # deleted in here between the CAS and the set/append. Change based on usage
    # volume and parallellization
    if result.nil?
      connection.set(message.username, message.id)
    elsif !result # someone else modified the value before we got there
      connection.append(message.username, "|#{message.id}")
    end
  end
  
  def self.connection
    options = { :namespace => MEMCACHE_NAMESPACE, :compress => true }
    @@connection ||= Dalli::Client.new("#{MEMCACHE_HOST}:#{MEMCACHE_PORT}", 
                       options)
  end
end
