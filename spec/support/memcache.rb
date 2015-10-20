RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  
  config.before(:suite) do
    begin
      HotStorage.connection.flush_all
    end
  end
end