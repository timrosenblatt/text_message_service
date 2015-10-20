class MessagePresenter
  def initialize(message)
    @message = message
  end
  
  # Only include attributes that should be public instead of removing
  # private ones, in case new attributes get added to the model
  def as_json(options={})
    # super(only: [:id, :username, :text, :expiration_date])
    
    public_attributes = {}
    public_attributes[:id] = @message.attributes['id']
    public_attributes[:username] = @message.attributes['username']
    public_attributes[:text] = @message.attributes['text']
    public_attributes[:expiration_date] = @message.attributes['expiration_date']

    public_attributes
  end
end