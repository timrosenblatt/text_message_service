require 'rails_helper'

# This spec is written in a way that's tightly coupled to behavior in Message
# I'm ok with this for now since the two pieces of functionality are tightly
# coupled by definition, but this could be improved by refactoring HotStorage
# in a way that wasn't so tightly coupled -- maybe have HotStorage#store(k,v)
# be it's own thing and test that interaction separately
RSpec.describe HotStorage do
  xit 'will be refactored to facilitate testing'
  
  it 'stores message' do
    m = create :message
    expect(HotStorage.connection.get(m.id)).to eq(MessagePresenter.new(m).as_json)
  end
  
  it 'expires messages automatically' do
    m = create :message, timeout: 1
    sleep(1)
    expect(HotStorage.connection.get(m.id)).to be_nil
  end
end