Simply AES
==========

Proper cryptography is easy to get wrong, and the Ruby stdlib adapters to OpenSSL's implentations of various encryption algorithms are often cumbersome to work with, expecting the developer to understand a great deal of terminology.

SimplyAES provides a simple, straight-forward interface for securely encrypting data in Ruby using key-based AES-256, the most secure variant of the [*Advanced Encryption Standard*][AES], complete with securely-generated initialisation vectors.

[AES]: http://en.wikipedia.org/wiki/Advanced_Encryption_Standard

[![Build Status](https://travis-ci.org/simplymeasured/simply-aes.svg?branch=develop)](https://travis-ci.org/simplymeasured/simply-aes)
[![Inline docs](http://inch-ci.org/github/simplymeasured/simply-aes.svg?branch=develop)](http://inch-ci.org/github/simplymeasured/simply-aes)
[![Gem Version](https://badge.fury.io/rb/simply-aes.svg)](http://badge.fury.io/rb/simply-aes)

Installation
------------

SimplyAES is available on rubygems.org:

    `gem install simply-aes`

Basic Usage
-----------

~~~ ruby
require 'simply-aes'

# Create a Cipher object; unless provided,
# a secure-random key will be generated.
cipher = SimplyAES.new # => <SimplyAES::Cipher:70293125591140>

# By default, the Cipher uses the Bytes formatter,
# so byte data is emitted as a string of raw bytes.
cipher.key # => "\x91\xD4\xEA=-\xC1\xB6\xE3\xDBP&\xDC\xB6\xFE\xDA\xF1\xF0L\x8Fz\e\xF7k]\x15\x9A\x9B8\xB1\xF3\xE3\xEE"

# All public methods take a `:format` option,
# which can be used to provide a format-helper;
# let's use `hex` which is easier to work with:
cipher.key(format: :hex) # => "91d4ea3d2dc1b6e3db5026dcb6fedaf1f04c8f7a1bf76b5d159a9b38b1f3e3ee"

# We can encrypt strings very easily:
secret = cipher.dump('Hello, World!', format: :hex) # => "521735c29ca1a6ae1a8fca49a9fb28ed8bf5d1bce3b39eb0286ea9c6b5dc286f"

# We can also decrypt strings; here,
# the format argument tells us how
# the ciphertext is formatted:
cipher.load(secret, format: :hex) # => 'Hello, World!'

# Attempting to load a ciphertext with an incorrect key emits an exception:
SimplyAES.new.load(secret, format: :hex) # !> SimplyAES::Cipher::LoadError
~~~

Interoperability
----------------

The ciphertext from SimplyAES can be decrypted easily by _any_ AES-compliant tool or library, with the following hints:

In SimplyAES, a secure-random initialisation vector is generated for each encryption unless explicitly given, and the 16-byte IV is returned with the ciphertext;
this means that two identical strings encrypted with the same key will have substantially different representations, making it harder for an attacker to correlate encrypted data.
Because the IV does not need to be kept [secret][iv-requirements], SimplyAES emits the iv+ciphertext as a single byte string.

[iv-requirements]: http://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Initialization_vector_.28IV.29

~~~
+-------- 16-byte IV ----------++--- unbounded payload size --->
|                              ||
521735c29ca1a6ae1a8fca49a9fb28ed8bf5d1bce3b39eb0286ea9c6b5dc286f
~~~

To decrypt AES ciphertext that has been encrypted using another library, simply prepend the IV (in the same format as the encrypted data) to the ciphertext:

~~~ ruby
ciphertext = '8bf5d1bce3b39eb0286ea9c6b5dc286f'
iv         = '521735c29ca1a6ae1a8fca49a9fb28ed'

cipher.load(iv+ciphertext, format: :hex) # => 'Hello, World!'
~~~

To decrypt a SimplyAES iv+ciphertext payload, simply use the first 16 bytes as the IV, and the remaining as the ciphertext.

~~~ ruby
# encoding: BINARY
key = "\x91\xD4\xEA=-\xC1\xB6\xE3\xDBP&\xDC\xB6\xFE\xDA\xF1\xF0L\x8Fz\e\xF7k]\x15\x9A\x9B8\xB1\xF3\xE3\xEE"

payload = "R\x175\xC2\x9C\xA1\xA6\xAE\x1A\x8F\xCAI\xA9\xFB(\xED\x8B\xF5\xD1\xBC\xE3\xB3\x9E\xB0(n\xA9\xC6\xB5\xDC(o"
iv = payload[0...16] # => "R\x175\xC2\x9C\xA1\xA6\xAE\x1A\x8F\xCAI\xA9\xFB(\xED"
ciphertext = payload[16..-1] # => "\x8B\xF5\xD1\xBC\xE3\xB3\x9E\xB0(n\xA9\xC6\xB5\xDC(o"

cipher = OpenSSL::Cipher.new('AES-256-CBC')
cipher.decrypt
cipher.key = key
cipher.iv = iv

decrypted = (cipher.update(ciphertext) + cipher.final) # => 'Hello, World!'
~~~

Advanced Usage
--------------

~~~ ruby
require 'simply-aes'

# The Cipher can be initialized with a default formatter:
cipher = SimplyAES.new(format: :base64)

# All byte-data respects the default format, unless overridden.
cipher.key # => "Okve+PUasFuqB7zONT3XgCz0adJN3a6gr58k+/rve1E="
~~~

License
-------

SimplyAES is Apache 2 Licensed.
