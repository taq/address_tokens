require "test_helper"
require_relative '../lib/state_not_found'
require_relative '../lib/city_not_found'

describe AddressTokens::Matcher do
  before do
    @finder = AddressTokens::Finder.new('this is some mixed tokens on address 123 neighborhood sao José do Rio Preto -  SP')
    @finder.load(:states, '/tmp/states.yml')
    @finder.load(:cities, '/tmp/cities.yml')
    @finder.find
    @matcher = AddressTokens::Matcher.new(@finder)
  end

  describe 'state' do
    it 'must extract' do
      matches = @matcher.match(@finder.string)
      expect(matches[:state_abbr]).must_equal 'SP'
      expect(matches[:state_name]).must_equal 'São Paulo'
      expect(matches[:state_start_at]).must_equal 76
    end
  end

  describe 'city' do
    it 'wont find with weird state' do
      -> {
        expect(@matcher.match('address here city - XX'))
      }.must_raise AddressTokens::StateNotFound
    end

    it 'wont find with weird city' do
      #-> {
        #expect(@matcher.match('address here city - SP'))
      #}.must_raise AddressTokens::CityNotFound
    end

    it 'must extract by exact match' do
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood São José do Rio Preto -  SP')
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_start_at]).must_equal 54
    end

    it 'must extract by exact match removing spaces' do
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood São    José  do     Rio    Preto   -  SP')
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_start_at]).must_equal 54
    end

    it 'must extract transliterated' do
      matches = @matcher.match @finder.string
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_start_at]).must_equal 54
    end
  end
end
