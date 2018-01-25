require "test_helper"

describe AddressTokens::Matcher do
  before do
    raise IOError, 'States file not found' if !File.exist?('/tmp/states.yml')
    raise IOError, 'Cities file not found' if !File.exist?('/tmp/cities.yml')

    @finder = AddressTokens::Finder.new('this is some mixed tokens on address 123 neighborhood 15085-110 sao José do Rio Preto -  SP')
    @finder.state_separator = '-'
    @finder.zip_format = AddressTokens::Zip::BR
    @finder.load(:states, '/tmp/states.yml')
    @finder.load(:cities, '/tmp/cities.yml')
    @finder.find
    @matcher = AddressTokens::Matcher.new(@finder)
    @github = '88 Colin P Kelly Jr St San Francisco, CA 94107'
  end

  describe 'state' do
    it 'must extract' do
      matches = @matcher.match(@finder.string)
      expect(matches[:state_abbr]).must_equal 'SP'
      expect(matches[:state_name]).must_equal 'São Paulo'
      expect(matches[:state_start_at]).must_equal 86
    end

    it 'must extract from Github' do
      @finder.state_separator = ','
      matches = @matcher.match(@github)
      expect(matches[:state_abbr]).must_equal 'CA'
      expect(matches[:state_name]).must_equal 'California'
      expect(matches[:state_start_at]).must_equal 36
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

    it 'must extract by exact match, from Github' do
      @finder.state_separator = ','
      matches = @matcher.match(@github)
      expect(matches[:city_name]).must_equal 'San Francisco'
      expect(matches[:city_string]).must_equal 'San Francisco'
      expect(matches[:city_start_at]).must_equal 23
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
      expect(matches[:city_start_at]).must_equal 64
    end

    it 'must extract written on a different way' do
      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood s J do R Preto -  SP'
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 's J do R Preto'
      expect(matches[:city_start_at]).must_equal 54

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
      expect(matches[:city_start_at]).must_equal 54

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
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood 15085-110 São José do Rio Preto -  SP')
      expect(matches[:address]).must_equal @address
    end

    it 'must extract by exact match, from Github' do
      @finder.state_separator = ','
      matches = @matcher.match(@github)
      expect(matches[:address]).must_equal '88 Colin P Kelly Jr St'
    end

    it 'must extract without zipcode' do
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood São José do Rio Preto -  SP')
      expect(matches[:address]).must_equal @address
    end

    it 'must extract by exact match removing spaces' do
      matches = @matcher.match('this is some mixed tokens on address 123 neighborhood 15085-110 São    José  do     Rio    Preto   -  SP')
      expect(matches[:address]).must_equal @address
    end

    it 'must extract transliterated' do
      matches = @matcher.match @finder.string
      expect(matches[:address]).must_equal @address
    end

    it 'must extract written on a different way' do
      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood 15085-110 s J do R Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood 15085-110 s J do Rio Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood 15085-110 São J do Rio Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood 15085-110 São José do R Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood 15085-110 S. J. do R. Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood 15085-110 Rib Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood 15085-110 Rib. Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood 15085-110 S J R Preto -  SP'
      expect(matches[:address]).must_equal @address

      matches = @matcher.match 'this is some mixed tokens on address 123 neighborhood 15085-110 S J Rio Preto -  SP'
      expect(matches[:address]).must_equal @address
    end
  end

  describe 'zipcode' do
    before do
      @finder.zip_format = AddressTokens::Zip::BR
    end

    it 'must find zipcode' do
      matches = @finder.find
      expect(matches[:zipcode]).must_equal '15085-110'
      expect(matches[:zipcode_string]).must_equal '15085-110'
    end

    it 'wont find zipcode' do
      matches = @finder.find @finder.string.sub(/15085-110/, '1508x-x10')
      expect(matches[:zipcode]).must_be_nil
      expect(matches[:zipcode_string]).must_be_nil
    end

    it 'must find zipcode with different format' do
      matches = @finder.find @finder.string.sub(/15085-110/, '15085110')
      expect(matches[:zipcode]).must_equal '15085-110'
      expect(matches[:zipcode_string]).must_equal '15085110'
    end

    it 'must find zipcode even on the end of string' do
      matches = @finder.find @finder.string.sub(/15085-110/, '') + ' 15085-110'
      expect(matches[:zipcode]).must_equal '15085-110'
      expect(matches[:zipcode_string]).must_equal '15085-110'
    end

    it 'must find github zipcode' do
      @finder.zip_format      = AddressTokens::Zip::US
      @finder.state_separator = ','
      matches = @finder.find @github
      expect(matches[:zipcode]).must_equal '94107'
      expect(matches[:zipcode_string]).must_equal '94107'
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

    it 'can use the find method to search for it' do
      result = @finder.find('Rua das Couves, 123, Centro, Ribeirão Preto - SP')
      expect(result[:state_abbr]).must_equal 'SP'
      expect(result[:state_name]).must_equal 'São Paulo'
      expect(result[:city_name]).must_equal  'Ribeirão Preto'
      expect(result[:address]).must_equal    'Rua das Couves, 123, Centro,'
    end
  end

  describe 'bluefish' do
    it 'will find us' do
      @finder.state_separator = '-'
      matches = @matcher.match 'Rua Tratado de Tordesihas, 88, Pq. Estoril, S. J. do Rio Preto - SP'
      expect(matches[:state_abbr]).must_equal 'SP'
      expect(matches[:state_name]).must_equal 'São Paulo'
      expect(matches[:state_start_at]).must_equal 63
      expect(matches[:city_name]).must_equal 'São José do Rio Preto'
      expect(matches[:city_string]).must_equal 'S. J. do Rio Preto'
      expect(matches[:city_start_at]).must_equal 44
      expect(matches[:address]).must_equal 'Rua Tratado de Tordesihas, 88, Pq. Estoril,'
    end
  end
end
