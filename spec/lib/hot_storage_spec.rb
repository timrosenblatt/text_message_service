require 'rails_helper'

RSpec.describe HotStorage do
  context 'storing messages' do
    it 'works' do
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
  end
  
  context 'getting messages' do
    it 'works' do
      m = create :message
      HotStorage.store_message(m)
    
      result = HotStorage.get_messages_for(m.username)
    
      expect(result.size).to eq(1)
      expect(result.first[:id]).to eq(m.id)
    end
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