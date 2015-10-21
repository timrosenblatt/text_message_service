require 'rails_helper'

RSpec.describe CreateMessageInteractor do
  it 'creates a message' do
    params = attributes_for :message
    
    expect{CreateMessageInteractor.create_message(params)}.
      to change{Message.count}.by(1)
  end
  
  it 'talks to the HotStorage module' do
    allow(HotStorage).to receive(:store_message)
    params = attributes_for :message
    
    CreateMessageInteractor.create_message(params)
    
    expect(HotStorage).to have_received(:store_message)
  end
end
