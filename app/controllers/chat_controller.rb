class ChatController < ApplicationController
  # This is being created as a public API, no authorization of _any_ kind
  skip_before_action :verify_authenticity_token
  
  def create
    head :bad_request and return if params[:username].nil?
    head :bad_request and return if params[:text].nil?
    
    username = params[:username]
    text = params[:text]
    timeout = params[:timeout].to_i unless params[:timeout].nil?
    
    message = CreateMessageInteractor.create_message username: username, 
      text: text, 
      timeout: timeout
    
    render json: { id: message.id }, status: :created
  end
  
  def show
    id = params[:id].to_i
    head :bad_request and return unless id != 0
    message = Message.find(params[:id])
    
    render json: MessagePresenter.new(message)
  rescue ActiveRecord::RecordNotFound
    head :not_found and return
  end
  
  def show_all
    head :bad_request and return if params[:username].nil?
    
    render json: HotStorage.get_messages_for(params[:username])
  end
end
