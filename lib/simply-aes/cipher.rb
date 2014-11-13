# encoding: utf-8

require 'simply-aes/format'
require 'simply-aes/cipher/error'

require 'openssl'

module SimplyAES
  # The Cipher is the heart of SimplyAES, and can be used to load ciphertext or
  # to dump a string's ciphertext with a given key or a securely-generated one.
  class Cipher
    # @overload initialize(options)
    # @overload initialize(key, options)
    #   @param key [String] a 32-byte (256-bit) string
    #     If not provided, a secure random key will be generated
    #   @param options [Hash{Symbol=>Object}]
    #   @option options [Symbol, SimplyAES::Format] (:bytes)
    #     The format is used to load provided data, including the given key,
    #     and as a default encoder/decoder of encrypted data; this can be
    #     overridden in the #load and #dump methods.
    #   @raise [SimplyAES::Cipher::Error]
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def initialize(*args)
      options = (args.last.is_a?(Hash) ? args.pop.dup : {})

      @format = Format[options.delete(:format) { :bytes }]

      # extract the given key, or securely generate one
      @key   = format.load(args.pop) unless args.empty?
      @key ||= native_cipher.random_key

      # validate initialisation
      fail(ArgumentError, 'invalid key length') unless @key.bytesize == 32
      fail(ArgumentError, 'wrong number of arguments') unless args.empty?
      fail(ArgumentError, "unknown options: #{options}") unless options.empty?
    rescue => err
      raise Error, "failed to initialize #{self.class.name} (#{err})"
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param options [Hash{Symbol=>Object}]
    # @option options [Symbol] :format (default: self.format)
    # @return [String] formatted string
    def key(options = {})
      format(options).dump(@key.dup)
    end

    # @param plaintext [String]
    # @param options [Hash{Symbol=>Object}]
    # @option options [String] :iv (default: secure random iv)
    #   up to 16 bytes, used as an initialisation vector
    # @option options [Symbol] :format (default: self.format)
    # @return iv_ciphertext [String] binary string
    # @raise SimplyAES::Cipher::DumpError
    def dump(plaintext, options = {})
      encipher = native_cipher(:encrypt)

      # ensure a 16-byte initialisation vector
      iv = options.fetch(:iv) { encipher.random_iv }
      fail(ArgumentError, 'iv must be 16 bytes') unless iv.bytesize == 16
      encipher.iv = iv

      ciphertext = encipher.update(plaintext) + encipher.final

      format(options).dump(iv + ciphertext)
    rescue => err
      raise DumpError, err.message
    end
    alias_method(:encrypt, :dump)

    # @param iv_ciphertext [String]
    # @option options [Symbol] :format (default: self.format)
    # @return plaintext [String]
    # @raise SimplyAES::Cipher::LoadError
    def load(iv_ciphertext, options = {})
      @key || fail(ArgumentError, 'key not provided!')

      # if the IV is given as an argument, inject it to the ciphertext
      given_iv = options[:iv]
      given_iv && (iv_ciphertext = given_iv + iv_ciphertext)

      # shift the 16-byte initialisation vector from the front
      iv, ciphertext = format(options).load(iv_ciphertext).unpack('a16a*')

      decipher = native_cipher(:decrypt)
      decipher.iv = iv

      decipher.update(ciphertext) + decipher.final
    rescue => err
      raise LoadError, err.message
    end
    alias_method(:decrypt, :load)

    # @api private
    # @return [String]
    def inspect
      "<#{self.class.name}:#{__id__}>"
    end

    # @api private
    # @return [SimplyAES::Format]
    def format(options = {})
      Format[options.fetch(:format) { @format }]
    end

    private

    # Returns an AES-256-CBC OpenSSL::Cipher object pre-configured with the
    # requested mode and our key; used internally in initialize, load,
    # and dump.
    #
    # @api private
    # @param mode [:encode, :decode]
    # @return [OpenSSL::Cipher]
    def native_cipher(mode = nil)
      ::OpenSSL::Cipher.new('AES-256-CBC').tap do |cipher|
        mode && cipher.public_send(mode)
        @key && cipher.key = @key
      end
    end
  end
end
