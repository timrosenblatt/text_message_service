require 'rails_helper'

RSpec.describe Message, :type => :model do
  it 'automatically sets expiration date' do
    m = build :message
    allow(m).to receive(:set_expiration_date)
  
    m.save
  
    expect(m).to have_received(:set_expiration_date)
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
