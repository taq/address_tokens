require "test_helper"

describe AddressTokens::Finder do
  before do
    @finder = AddressTokens::Finder.new('this is some mixed tokens on address 123 neighborhood sao José do Rio Preto -  SP')
    @finder.state_separator = '-'
  end 

  describe 'version' do
    it 'must have one' do
      expect(::AddressTokens::VERSION).wont_be_nil
    end
  end

  describe 'constructor' do
    it 'wont accept nil strings' do
      -> {
        AddressTokens::Finder.new(nil)
      }.must_raise Exception
    end

    it 'wont accept empty strings' do
      -> {
        AddressTokens::Finder.new('')
      }.must_raise Exception
    end

    it 'accept non empty strings' do
      expect(AddressTokens::Finder.new('this is a test')).wont_be_nil
    end
  end

  describe 'states' do
    it 'must have an accessor' do
      expect(@finder).must_respond_to :states
    end

    it 'wont load states, if file not found' do
      -> {
        @finder.load(:states, '/tmp/comeonyoudonthavesuchafiledoyou.txt')
      }.must_raise IOError
    end

    it 'wont load states, if no YAML file' do
      -> {
        @finder.load(:states, "#{File.dirname(__FILE__)}/test.txt")
      }.must_raise TypeError
    end

    it 'must load states' do
      @finder.load(:states, '/tmp/states.yml')
      expect(@finder.states).must_be_kind_of Hash
      expect(@finder.states['SP']).must_equal 'São Paulo'
    end
  end

  describe 'cities' do
    it 'must have an accessor' do
      expect(@finder).must_respond_to :cities
    end

    it 'wont load cities, if file not found' do
      -> {
        @finder.load(:cities, '/tmp/comeonyoudonthavesuchafiledoyou.txt')
      }.must_raise IOError
    end

    it 'wont load cities, if no YAML file' do
      -> {
        @finder.load(:cities, "#{File.dirname(__FILE__)}/test.txt")
      }.must_raise TypeError
    end

    it 'must load cities' do
      @finder.load(:cities, '/tmp/cities.yml')
      expect(@finder.cities).must_be_kind_of Hash
      expect(@finder.cities['SP'].include?('São José do Rio Preto')).must_equal true
    end
  end

  describe 'find' do
    it 'wont find with no states' do
      -> {
        @finder.load(:cities, '/tmp/cities.yml')
        @finder.find
      }.must_raise ArgumentError
    end

    it 'wont find with no cities' do
      -> {
        @finder.load(:states, '/tmp/states.yml')
        @finder.find
      }.must_raise ArgumentError
    end

    it 'must transliterate and load city tokens' do
      @finder.load(:states, '/tmp/states.yml')
      @finder.load(:cities, '/tmp/cities.yml')
      @finder.find

      expect(@finder.city_tokens['AC'][-10]).must_equal ['Plácido de Castro', 'placido de castro', ['placido', 'de', 'castro']]
      expect(@finder.city_tokens['AC'][-1]).must_equal  ['Xapuri', 'xapuri']
    end
  end
end
