module AddressTokens
  module Zip
    US = { format: /(\d{5})/ }
    BR = { format: /(\d{5})-?(\d{3})/, join: ['-'] }
  end
end
