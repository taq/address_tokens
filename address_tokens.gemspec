
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "address_tokens/version"

Gem::Specification.new do |spec|
  spec.name          = "address_tokens"
  spec.version       = AddressTokens::VERSION
  spec.authors       = ["Eustaquio Rangel"]
  spec.email         = ["taq@eustaquiorangel.com"]

  spec.summary       = %q{Find address tokens on a string}
  spec.description   = %q{Always want to find where address, city and state are on a string? Use this gem.}
  spec.homepage      = "http://github.com/taq/address_tokens"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "i18n", "~> 0.7"

  spec.signing_key = '/home/taq/.gemcert/gem-private_key.pem'
  spec.cert_chain = ['gem-public_cert.pem']
end
