# crypt [![Build Status](https://travis-ci.org/coffeejunk/crypt19.png?branch=master)](https://travis-ci.org/coffeejunk/crypt19)

## Mirror/Fork

This is a mirror (or fork if you will) of the crypt19 gem. It vanished from
rubygems in February of 2013, which made me a very sad panda. I rescued the
code from my local installation and here it is again..

I will try to continue maintenance, however any help is very welcome!

## Description

The Crypt library is a pure-ruby implementation of a number of popular
encryption algorithms. Block cyphers currently include Blowfish, GOST, IDEA,
Rijndael (AES), and RC6. Cypher Block Chaining (CBC) has been implemented.

Crypt is written entirely in ruby so deployment is simple - no platform
concerns, no library dependencies, nothing to compile.

## Testing

Tests run on [Travis CI](https://travis-ci.org/coffeejunk/crypt19). It
currently is verified to work on the following ruby versions:

* mri 1.8.7
* mri 1.9.3
* jruby 1.8 mode
* rubinius 1.8 mode
* rubinius 1.9 mode

## Installation
    gem install crypt19-rb

## Credits
### Contributors
Updated and maintained by Jonathan Rudenberg (2009)

RC6 algorithm implementation by Alexey Lapitsky (2009)

Block padding fix by Daniel Brahneborg (2007)

Originally written by Richard Kernahan (2005/2006)

### References
The Blowfish code was adapted from Bruce Schneier's [reference C code](http://www.schneier.com/blowfish-download.html).

The GOST code was adapted from Wei Dai's C++ code from the [Crypto++ project](http://sourceforge.net/projects/cryptopp).

The IDEA code was based on the reference [C implementation](http://web.archive.org/web/20000816173624/www.ascom.ch/infosec/downloads.html) once published by MediaCrypt.

The Rijndael code was adapted from the reference [ANSI C code](http://www.esat.kuleuven.ac.be/~rijmen/rijndael/rijndael-fst-3.0.zip) by Paulo Barreto and Vincent Rijmen.

### License
This work is placed in the public domain. See LICENSE for algorithm licensing details.
