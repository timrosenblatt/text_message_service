require 'rails_helper'

RSpec.describe ChatController, :type => :controller do
  # First specs directly from requirements
  
  # The message data returned by each endpoint varies slightly in the spec
  # Changing it will only require changing an attribute or two, so get
  # it working first then revise if needed
  
  context 'creating new messages' do
    it 'creates new messages' do
      post :create, username: 'timrosenblatt', text: 'Hi Tim!', timeout: 120
    
      expect(response).to have_http_status(:created)
    
      parsed_response = JSON.parse response.body
      expect(parsed_response['id']).to be_a(Integer)
      expect(parsed_response.keys.size).to eq(1)
    end
  
    it 'does not require a timeout' do
      post :create, username: 'timrosenblatt', text: 'Hi Tim!'
    
      expect(response).to have_http_status(:created)
    end
    
    it 'does require a username' do
      post :create, text: 'Hi Tim!'
    
      expect(response).to have_http_status(:bad_request)
    end
    
    it 'does require message text' do
      post :create, username: 'timrosenblatt'
    
      expect(response).to have_http_status(:bad_request)
    end
  end
  
  context 'showing single messages' do
    it 'works' do
      m = create :message
    
      get :show, id: m.id
    
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse response.body
      expect(parsed_response['id']).to eq(m.id)
      expect(parsed_response['username']).to eq(m.username)
      expect(parsed_response['text']).to eq(m.text)
      exp_date = Time.parse(parsed_response['expiration_date']).to_i
      expect(exp_date).to eq(m.expiration_date.to_i)
    end
    
    it 'handles non-existent ids' do
      get :show, id: 1234567890
      
      expect(response).to have_http_status(:not_found)
    end
    
    it 'handles bad ids' do
      get :show, id: 'dog'
      
      expect(response).to have_http_status(:bad_request)
    end
  end
  
  context 'returning all messages for a user' do
    it 'works' do
      messages = create_list :message, 3, username: 'timrosenblatt'
    
      get :show_all, username: 'timrosenblatt'
    
      parsed_response = JSON.parse response.body
    
      expect(response).to have_http_status(:ok)
      expect(parsed_response).to be_a(Array)
      expect(parsed_response.size).to be(3)
      expect(parsed_response[0]['username']).to eq('timrosenblatt')
      expect(parsed_response[1]['username']).to eq('timrosenblatt')
      expect(parsed_response[2]['username']).to eq('timrosenblatt')
      message_ids = messages.map(&:id)
      expect(message_ids).to include(parsed_response[0]['id'])
      expect(message_ids).to include(parsed_response[1]['id'])
      expect(message_ids).to include(parsed_response[2]['id'])
      message_texts = messages.map(&:text)
      expect(message_texts).to include(parsed_response[0]['text'])
      expect(message_texts).to include(parsed_response[1]['text'])
      expect(message_texts).to include(parsed_response[2]['text'])
      message_expires = messages.map do |message|
        message.expiration_date.to_i
      end
      expect(message_expires).to include(Time.parse(parsed_response[0]['expiration_date']).to_i)
      expect(message_expires).to include(Time.parse(parsed_response[1]['expiration_date']).to_i)
      expect(message_expires).to include(Time.parse(parsed_response[2]['expiration_date']).to_i)
    end
    
    # This functionality is desirable, because if we assume every username
    # exists, the code can return directly from HotStorage without having to
    # consult DB to find out if a user exists
    it 'handles invalid usernames' do
      get :show_all, username: 'clarkkent'
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('[]')
    end
  end
end
