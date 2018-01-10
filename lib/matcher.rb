module AddressTokens
  class Matcher
    def initialize(finder)
      @finder = finder
    end

    def match(str)
      zip_info     = find_zip(str)
      state_info   = find_state(str, zip_info)
      city_info    = find_city(str, state_info)
      address_info = remove_zip(find_address(str, city_info), zip_info)

      {
        state_abbr:     state_info[:state],
        state_name:     @finder.states[state_info[:state]],
        state_start_at: state_info[:start_at],
        city_name:      city_info[:city_name],
        city_string:    city_info[:city_string],
        city_start_at:  city_info[:start_at],
        address:        address_info[:address],
        zipcode:        zip_info[:zip],
        zipcode_string: zip_info[:zip_string]
      }
    end

    private

    def remove_end_zip_for_state(str, zip_info)
      return str if !@finder.zip_format[:format].to_s.include?(@finder.state_separator) 
      return str if !zip_info
      return str if !zip_info[:zip_on_end]
      str.strip.sub(Regexp.new("#{zip_info[:zip_string]}\\z"), '')
    end

    def find_state(str, zip_info)
      str       = remove_end_zip_for_state(str, zip_info)
      last_char = str.rindex(@finder.state_separator)
      token     = str[last_char .. -1]
      token     = token.gsub(/\s{2,}/, ' ')
      matches   = token.match(Regexp.new("#{@finder.state_separator}\s?(?<state>\\w+)"))
      { state: matches[:state], start_at: last_char }
    end

    def find_city(str, state_info)
      cities = @finder.city_tokens[state_info[:state]]
      raise StateNotFound, "State #{state_info[:state]} not found on state data" if cities.nil?

      without_state  = str[0 .. state_info[:start_at] - 1].strip.gsub(/\s{2,}/, ' ')
      transliterated = I18n.transliterate(without_state).downcase

      exact_or_trans = find_city_by_exact_or_trans(cities, without_state, transliterated)
      return exact_or_trans if !exact_or_trans.nil?

      tokenized = find_city_by_tokenized(cities, transliterated, str)
      return tokenized if !tokenized.nil?

      raise CityNotFound, "City not found"
    end

    def find_city_by_tokenized(cities, transliterated, str)
      choices = []

      cities.each do |city|
        tokens      = transliterated.split
        city_tokens = I18n.transliterate(city[0]).downcase.split

        if tokens[-1] == city_tokens[-1]
          first_tokens              = tokens.map         { |token| token[0] }.join
          first_city_tokens         = city_tokens.map    { |token| token[0] }.join
          first_shorten_city_tokens = city_tokens.select { |token| token.size > 2 }.map { |token| token[0] }.join

          choices << [city[0], first_tokens, first_city_tokens]         if Regexp.new("#{first_city_tokens}$").match?         first_tokens
          choices << [city[0], first_tokens, first_shorten_city_tokens] if Regexp.new("#{first_shorten_city_tokens}$").match? first_tokens
        end
      end

      return nil if choices.size == 0

      reversed = choices.sort_by { |choice| choice[2].size }.reverse
      regex    = reversed[0][2].scan(/./).map { |char| "#{char}[\\p{Latin}\.]*\\s+"}.join.strip[0..-4]
      matches = Regexp.new(regex, 'i').match(str)
      { city_name: reversed[0][0], city_string: matches ? matches[0].strip : nil, start_at: matches ? str.index(matches[0].strip) : -1 }
    end

    def find_city_by_exact_or_trans(cities, without_state, transliterated)
      cities.each do |city|
        exact = Regexp.new("#{city[0]}$")
        trans = Regexp.new("#{city[1]}$")

        return { city_name: city[0], start_at: without_state.rindex(city[0]) , city_string: city[0] } if exact.match? without_state
        return { city_name: city[0], start_at: transliterated.rindex(city[1]), city_string: without_state[transliterated.rindex(trans)..-1] } if trans.match? transliterated
      end
      nil
    end

    def find_address(str, city_info)
      return { address: str[0 ... city_info[:start_at]].strip } if city_info[:start_at] > 0
      { address: str.split(city_info[:city_string])[0].strip }
    end

    def find_zip(str)
      matches = str.match @finder.zip_format[:format]
      joiner  = @finder.zip_format[:join] || [ nil ]
      zip     = matches ? matches[1..-1].zip(joiner).flatten.join : nil
      zip_str = matches ? matches[0] : nil
      { zip: zip, zip_string: zip_str, zip_on_end: zip_str && Regexp.new("#{zip_str}\\z").match?(str) }
    end

    def remove_zip(address_info, zip_info)
      return address_info if !address_info || !zip_info || !zip_info[:zip_string]
      address_info[:address] = address_info[:address].sub(zip_info[:zip_string], '').strip
      address_info
    end
  end
end
