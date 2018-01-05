require "test_helper"

describe AddressTokens::Finder do
  let(:finder) { AddressTokens::Finder.new('this is some mixed tokens on address 123 neighborhood sao José do Rio Preto -  SP') }

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
      expect(finder).must_respond_to :states
    end

    it 'wont load states, if file not found' do
      -> {
        finder.states = '/tmp/comeonyoudonthavesuchafiledoyou.txt'
      }.must_raise IOError
    end

    it 'wont load states, if no YAML file' do
      -> {
      finder.states = 'test.txt'
      }.must_raise TypeError
    end

    it 'must load states' do
      finder.states = '/tmp/states.yml'
      expect(finder.states).must_be_kind_of Hash
      expect(finder.states['SP']).must_equal 'São Paulo'
    end
  end

  describe 'cities' do
    it 'must have an accessor' do
      expect(finder).must_respond_to :cities
    end

    it 'wont load cities, if file not found' do
      -> {
        finder.cities = '/tmp/comeonyoudonthavesuchafiledoyou.txt'
      }.must_raise IOError
    end

    it 'wont load cities, if no YAML file' do
      -> {
      finder.cities = 'test.txt'
      }.must_raise TypeError
    end

    it 'must load cities' do
      finder.cities = '/tmp/cities.yml'
      expect(finder.cities).must_be_kind_of Hash
      expect(finder.cities['SP'].include?('São José do Rio Preto')).must_equal true
    end
  end
end
