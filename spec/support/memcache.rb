RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  
  config.before(:each) do
    HotStorage.send(:connection).flush_all
  end
end