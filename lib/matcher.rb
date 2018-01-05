module AddressTokens
  class Matcher
    def initialize(finder)
      @finder = finder
    end

    def match(str)
      state = find_state(str)

      {
        state: state
      }
    end

    private

    def find_state(str)
      last_char = str.rindex(@finder.state_separator)
      token     = str[last_char .. -1]
      token     = token.gsub(/\s{2,}/, ' ')
      matches   = token.match(Regexp.new("-\s?(?<state>\\w+)"))
      matches[:state]
    end
  end
end
