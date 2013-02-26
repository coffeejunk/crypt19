# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crypt/version'

Gem::Specification.new do |gem|
  gem.name          = "crypt19-rb"
  gem.version       = Crypt::VERSION
  gem.authors       = ["Jonathan Rudenberg", "Richard Kernahan", "Maximilian Haack"]
  gem.email         = ["mxhaack@gmail.com"]
  gem.description   = %q{Crypt is a pure-ruby implementation of a number of popular encryption algorithms. Block cyphers currently include Blowfish, GOST, IDEA, Rijndael (AES), and RC6. Cypher Block Chaining (CBC) has been implemented.}
  gem.summary       = %q{Crypt is a pure-ruby implementation of a number of popular encryption algorithms.}
  gem.homepage      = "https://github.com/coffeejunk/crypt19"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
