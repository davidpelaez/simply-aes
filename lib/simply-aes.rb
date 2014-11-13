# encoding: utf-8

require 'simply-aes/version'
require 'simply-aes/cipher'

# SimplyAES provides a simple, straight-forward interface for securely
# encrypting data in Ruby using key-based AES-256, the most secure variant of
# the [*Advanced Encryption Standard*][AES], complete with securely-generated
# initialisation vectors.
module SimplyAES
  # @see SimplyAES::Cipher#initialize
  def self.new(*args)
    Cipher.new(*args)
  end
end
