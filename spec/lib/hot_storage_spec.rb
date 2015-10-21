require 'rails_helper'

RSpec.describe HotStorage do
  it 'stores message' do
    m = create :message
    
    HotStorage.store_message(m)
    
    expect(HotStorage.connection.get(m.id)).to eq(MessagePresenter.new(m).as_json)
  end
  
  it 'expires messages automatically' do
    m = create :message, timeout: 1
    HotStorage.store_message(m)
    sleep(1)
    
    expect(HotStorage.connection.get(m.id)).to be_nil
  end
  
  it 'expires multiple messages automatically' do
    m1 = create :message, timeout: 2, username: 'tim'
    m2 = create :message, timeout: 1, username: 'tim'
    HotStorage.store_message(m1)
    HotStorage.store_message(m2)
    sleep(3)
    
    result = HotStorage.get_messages_for('tim')
    
    expect(result.size).to eq(0)
  end
  
  it 'handles different length timeouts' do
    m1 = create :message, timeout: 10, username: 'tim'
    m2 = create :message, timeout: 1, username: 'tim'
    HotStorage.store_message(m1)
    HotStorage.store_message(m2)
    sleep(1)
    
    result = HotStorage.get_messages_for('tim')
    
    expect(result.size).to eq(1)
  end
end