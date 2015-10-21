class CreateMessageInteractor
  def self.create_message(params)
    message = Message.create params
    HotStorage.store_message(message)
    message
  end
end