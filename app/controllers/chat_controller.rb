class ChatController < ApplicationController
  def create
    head :bad_request and return if params[:username].nil?
    head :bad_request and return if params[:text].nil?
    
    username = params[:username]
    text = params[:text]
    timeout = params[:timeout].to_i || 60
    expiration_date = Time.now + timeout.seconds
    
    # move this into an after-create
    message = Message.create username: username, 
      text: text, 
      expiration_date: expiration_date
    HotStorage.store_message(message, timeout)
    
    render json: { id: message.id }, status: :created
  end
  
  def show
    message = Message.find(params[:id])
    
    render json: MessagePresenter.new(message)
  end
  
  # Messages are written into hot storage as strings, so we just need to render
  def show_all
    head :bad_request and return if params[:username].nil?
    username = params[:username]
    
    render json: HotStorage.get_messages_for(username)
  end
end
