# crypt

## Description
The Crypt library is a pure-ruby implementation of a number of popular encryption algorithms. Block cyphers currently include Blowfish, GOST, IDEA, Rijndael (AES), and RC6. Cypher Block Chaining (CBC) has been implemented.

Crypt is written entirely in ruby so deployment is simple - no platform concerns, no library dependencies, nothing to compile.

This version is tested on MRI Ruby 1.8.6, 1.8.7, 1.9.1, 1.9.2-preview1, and JRuby 1.4.0.

## Usage
TODO See http://crypt.rubyforge.org/ for now.

## Installation
    gem install crypt19

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