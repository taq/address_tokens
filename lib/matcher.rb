module AddressTokens
  class Matcher
    def initialize(finder)
      @finder = finder
    end

    def match(str)
      state_info = find_state(str)
      city_info  = find_city(str, state_info)

      {
        state_abbr:     state_info[:state],
        state_name:     @finder.states[state_info[:state]],
        state_start_at: state_info[:start_at],
        city_name:      city_info[:city_name],
        city_start_at:  city_info[:start_at],
      }
    end

    private

    def find_state(str)
      last_char = str.rindex(@finder.state_separator)
      token     = str[last_char .. -1]
      token     = token.gsub(/\s{2,}/, ' ')
      matches   = token.match(Regexp.new("-\s?(?<state>\\w+)"))
      { state: matches[:state], start_at: last_char }
    end

    def find_city(str, state_info)
      cities = @finder.city_tokens[state_info[:state]]
      raise StateNotFound, "State #{state_info[:state]} not found on state data" if cities.nil?

      without_state  = str[0 .. state_info[:start_at] - 1].strip.gsub(/\s{2,}/, ' ')
      transliterated = I18n.transliterate(without_state).downcase

      exact_or_trans = find_city_by_exact_or_trans(cities, without_state, transliterated)
      return exact_or_trans if !exact_or_trans.nil?

      tokenized = find_city_by_tokenized(cities, transliterated)
      return tokenized if !tokenized.nil?

      raise CityNotFound, "City not found"
    end

    def find_city_by_tokenized(cities, transliterated)
      choices = []

      cities.each do |city|
        exact       = Regexp.new("#{city[0]}$")
        tokens      = transliterated.split
        city_tokens = I18n.transliterate(city[0]).downcase.split

        if tokens[-1] == city_tokens[-1]
          first_tokens      = tokens.map      { |token| token[0] }.join
          first_city_tokens = city_tokens.map { |token| token[0] }.join
          choices << [city[0], first_tokens, first_city_tokens] if Regexp.new("#{first_city_tokens}$").match? first_tokens
        end
      end

      return nil if choices.size == 0
      { city_name: choices.sort_by { |choice| choice[2].size }.reverse[0][0], start_at: -1 }
    end

    def find_city_by_exact_or_trans(cities, without_state, transliterated)
      cities.each do |city|
        exact = Regexp.new("#{city[0]}$")
        trans = Regexp.new("#{city[1]}$")

        return { city_name: city[0], start_at: without_state.rindex(city[0])  } if exact.match? without_state
        return { city_name: city[0], start_at: transliterated.rindex(city[1]) } if trans.match? transliterated
      end
      nil
    end
  end
end
