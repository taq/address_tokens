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

      without_state  = str[0 .. state_info[:start_at] - 1].strip
      transliterated = I18n.transliterate(without_state)

      cities.each do |city|
        exact = Regexp.new("#{city[0]}$")
        return { city_name: city[0], start_at: without_state.rindex(city[0]) } if without_state =~ exact
      end
      { city_name: nil, start_at: -1 }
    end
  end
end
