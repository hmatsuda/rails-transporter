require 'spec_helper'

RSpec.describe CustomArray do
  it 'can be initialized' do
    expect(CustomArray.new).to be_empty
  end
end
