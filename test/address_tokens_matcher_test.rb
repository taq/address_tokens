require "test_helper"

describe AddressTokens::Matcher do
  before do
    @finder = AddressTokens::Finder.new('this is some mixed tokens on address 123 neighborhood sao José do Rio Preto -  SP')
    @finder.load(:states, '/tmp/states.yml')
    @finder.load(:cities, '/tmp/cities.yml')
    @finder.find
    @matcher = @finder.matcher
  end

  describe 'state' do
    it 'must extract' do
      expect(@matcher.match(@finder.string)[:state]).must_equal 'SP'
    end
  end
end
