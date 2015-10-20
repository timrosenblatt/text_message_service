require 'rails_helper'

RSpec.describe Message, :type => :model do
  context 'automatically' do
    it 'sets expiration date' do
      m = build :message
      allow(m).to receive(:set_expiration_date)
    
      m.save
    
      expect(m).to have_received(:set_expiration_date)
    end
    
    # This needs to be refactored into an Interactor
    xit 'saves itself into hot storage' do
      m = build :message
      allow(m).to receive(:put_in_hot_storage)
    
      m.save
    
      expect(m).to have_receieved(:put_in_hot_storage)
    end
  end
  
  it 'talks to the HotStorage module' do
    allow(HotStorage).to receive(:store_message)
    m = build :message
    
    m.put_in_hot_storage
    
    expect(HotStorage).to have_received(:store_message)
  end
  
  it 'creates messages with a default timeout' do
    m = create :message, timeout: nil
    expect(m.timeout).to eq(Message.default_timeout)
  end
  
  it 'has a class-level default timeout that returns an Integer' do
    expect(Message.default_timeout).to be_a(Integer)
  end
  
  it 'has a timeout attribute' do
    m = build :message
    m.timeout = 1

    expect(m.timeout).to eq(1)
  end
end
