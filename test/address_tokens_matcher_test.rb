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

    it 'must extract state, using space separator' do
      @finder.state_separator = ' '
      @matcher = AddressTokens::Matcher.new(@finder)
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood sao José do Rio Preto SP')
      expect(matches[:state_abbr]).must_equal 'SP'
    end
  end

  describe 'city' do
    it 'wont find with weird state' do
      -> {
        expect(@matcher.match('address here city - XX'))
      }.must_raise AddressTokens::StateNotFound
    end

    it 'wont find with weird city' do
      -> {
        expect(@matcher.match('address here city - SP'))
      }.must_raise AddressTokens::CityNotFound
    end

    it 'must extract by exact match' do
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood São José do Rio Preto -  SP')
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'São José do Rio Preto'
      expect(matches[:city_start_at]).must_equal 54
    end

    it 'must extract by exact match removing spaces' do
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood São    José  do     Rio    Preto   -  SP')
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'São José do Rio Preto'
      expect(matches[:city_start_at]).must_equal 54
    end

    it 'must extract transliterated' do
      matches = @matcher.match @finder.string
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'sao José do Rio Preto'
      expect(matches[:city_start_at]).must_equal 54
    end

    it 'must extract written on a different way' do
      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood s J do R Preto -  SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 's J do R Preto'
      expect(matches[:city_start_at]).must_equal(-1)

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood s J do Rio Preto -  SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 's J do Rio Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood São J do Rio Preto -  SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'São J do Rio Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood São José do R Preto -  SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'São José do R Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood S. J. do R. Preto -  SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'S. J. do R. Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood Rib Preto -  SP'
      expect(matches[:city_name]).must_equal 'Ribeirão Preto'
      expect(matches[:city_string]).must_equal 'Rib Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood Rib. Preto -  SP'
      expect(matches[:city_name]).must_equal 'Ribeirão Preto'
      expect(matches[:city_string]).must_equal 'Rib. Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood S J R Preto -  SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'S J R Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood S J Rio Preto -  SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'S J Rio Preto'
    end
  end

  describe 'city, using space as state separator' do
    before do
      @finder.state_separator = ' '
      @matcher = AddressTokens::Matcher.new(@finder)
    end

    it 'wont find with weird city' do
      -> {
        expect(@matcher.match('address here city SP'))
      }.must_raise AddressTokens::CityNotFound
    end

    it 'must extract by exact match' do
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood São José do Rio Preto SP')
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'São José do Rio Preto'
      expect(matches[:city_start_at]).must_equal 54
    end

    it 'must extract by exact match removing spaces' do
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood São    José  do     Rio    Preto   SP')
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'São José do Rio Preto'
      expect(matches[:city_start_at]).must_equal 54
    end

    it 'must extract transliterated' do
      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood Sao    José  do     Rio    Preto   SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'Sao José do Rio Preto'
      expect(matches[:city_start_at]).must_equal 54
    end

    it 'must extract written on a different way' do
      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood s J do R Preto    SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 's J do R Preto'
      expect(matches[:city_start_at]).must_equal(-1)

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood s J do Rio Preto   SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 's J do Rio Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood São J do Rio Preto   SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'São J do Rio Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood São José do R Preto   SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'São José do R Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood S. J. do R. Preto   SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'S. J. do R. Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood Rib Preto   SP'
      expect(matches[:city_name]).must_equal 'Ribeirão Preto'
      expect(matches[:city_string]).must_equal 'Rib Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood Rib. Preto   SP'
      expect(matches[:city_name]).must_equal 'Ribeirão Preto'
      expect(matches[:city_string]).must_equal 'Rib. Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood S J R Preto   SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'S J R Preto'

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood S J Rio Preto   SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'S J Rio Preto'
    end
  end

  describe 'address' do
    before do
      @address = 'this is some mixed tokens on address 123 neighborhood'
    end

    it 'must extract by exact match' do
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood São José do Rio Preto -  SP')
      expect(matches[:address]).must_equal @address
    end

    it 'must extract by exact match removing spaces' do
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood São    José  do     Rio    Preto   -  SP')
      expect(matches[:address]).must_equal @address
    end

    it 'must extract transliterated' do
      matches = @matcher.match @finder.string
      expect(matches[:address]).must_equal @address
    end

    it 'must extract written on a different way' do
      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood s J do R Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood s J do Rio Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood São J do Rio Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood São José do R Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood S. J. do R. Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood Rib Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood Rib. Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood S J R Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood S J Rio Preto -  SP'
      expect(matches[:address]).must_equal @address
    end
  end

  describe 'string' do
    it 'can change after creating the object' do
      @finder.string = 'Rua das Couves, 123, Centro, Ribeirão Preto - SP'
      result = @finder.find
      expect(result[:state_abbr]).must_equal 'SP'
      expect(result[:state_name]).must_equal 'São Paulo'
      expect(result[:city_name]).must_equal  'Ribeirão Preto'
      expect(result[:address]).must_equal    'Rua das Couves, 123, Centro,'
    end
  end
end
