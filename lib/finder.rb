require 'yaml'
require 'i18n'

module AddressTokens
  class Finder
    attr_accessor :states, :cities, :state_separator
    attr_reader :city_tokens, :string

    def initialize(str)
      raise Exception, 'String is null or empty' if str.strip.size < 1
      @string, @states, @cities, = str, {}, {}
      I18n.config.available_locales = :en
      @state_separator = '-'
    end

    def load(var, file)
      load_file(var, file)
    end

    def find
      raise ArgumentError, 'No states found' if @states.size == 0
      raise ArgumentError, 'No cities found' if @cities.size == 0
      transliterate_cities
      Matcher.new(self).match(@string)
    end

    private

    def load_file(var, file)
      raise IOError, "File #{file} was not found" if !File.exist?(file)
      data = YAML.load(File.read(file))
      raise TypeError, "File #{file} is not a valid YAML file" if !data.kind_of?(Hash)
      instance_variable_set("@#{var}", data)
    end

    def transliterate_cities
      @city_tokens = {}

      for state, cities in @cities
        @city_tokens[state] = []
        
        for city in cities
          tokens = []
          city.gsub!(/\s{2,}/, ' ')
          tokens << city

          tdown = I18n.transliterate(city).downcase
          tokens << tdown
          
          splitted = tdown.split
          tokens << splitted if splitted.size > 1
          @city_tokens[state] << tokens
        end
      end
    end
  end
end
