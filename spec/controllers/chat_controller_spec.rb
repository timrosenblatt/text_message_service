require 'rails_helper'

RSpec.describe ChatController, :type => :controller do
  # First specs directly from UA-MFP requirements
  
  # The message data returned by each endpoint varies slightly in the spec
  # Changing it will only require changing an attribute or two, so get
  # it working first then revise if needed
  
  it 'creates new messages' do
    post :create, username: 'timrosenblatt', text: 'Hi Tim!', timeout: 120
    
    expect(response).to have_http_status(:created)
    
    parsed_response = JSON.parse response.body
    expect(parsed_response['id']).to be_a(Integer)
    expect(parsed_response.keys.size).to eq(1)
  end
  
  xit 'creates new messages with a default timeout' do
  end
  
  xit 'handles messages up to a certain size' do
  end
  
  it 'shows a single message' do
    # Replace this with a FactoryGirl create
    post :create, username: 'timrosenblatt', text: 'Hi Tim!', timeout: 120
    parsed_response = JSON.parse response.body
    msg_id = parsed_response['id']
    expiration_date = (Time.now + 120.seconds).utc.iso8601
    
    get :show, id: msg_id
    
    expect(response).to have_http_status(:ok)
    parsed_response = JSON.parse response.body
    expect(parsed_response['username']).to eq('timrosenblatt')
    expect(parsed_response['text']).to eq('Hi Tim!')
    exp_date = Time.parse(parsed_response['expiration_date']).to_i
    expect(exp_date).to eq(Time.parse(expiration_date).to_i)
  end
  
  it 'returns all messages for a user' do
    post :create, username: 'timrosenblatt', text: 'Hi Tim!', timeout: 120
    post :create, username: 'timrosenblatt', text: 'How are you', timeout: 120
    post :create, username: 'timrosenblatt', text: 'Lets hang', timeout: 120
    
    get :show_all, username: 'timrosenblatt'
    
    parsed_response = JSON.parse response.body
    expect(response).to have_http_status(:ok)
    expect(parsed_response).to be_a(Array)
    expect(parsed_response[0]['username']).to be('timrosenblatt')
    expect(parsed_response[0]['text']).to be('Hi Tim!')
    expect(parsed_response[0]['expiration_date']).to be('real value TBD')
    expect(parsed_response[1]['username']).to be('timrosenblatt1')
    expect(parsed_response[1]['text']).to be('Hi Tim!!!!')
    expect(parsed_response[1]['expiration_date']).to be('real value TBD')
  end
end
