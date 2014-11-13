# encoding: utf-8
# rubocop:disable Style/ModuleFunction

module SimplyAES
  # Implementations of SimplyAES::Format are formatting helpers,
  # used by SimplyAES::Cipher to dump byte-strings and to load
  # formatted byte-strings.
  module Format
    # @param  formatted  [String]
    # @return bytestring [String]
    def load(formatted)
      return super if defined?(super)
      fail(NotImplementedError)
    end

    # @param  bytestring [String]
    # @return formatted  [String]
    def dump(bytestring)
      return super if defined?(super)
      fail(NotImplementedError)
    end

    @implementations = {}

    def self.included(implementation)
      if (name = implementation.name)
        # @todo support alternate-paths
        short_name = name.split('::').last.downcase.to_sym
        self[short_name] = implementation
      end
    end

    def self.[]=(name, implementation)
      fail(ArgumentError, "not a #{self}") unless implementation <= self
      @implementations[name] = implementation
    end

    def self.[](name)
      return name if name.is_a?(Module) && name <= self

      @implementations.fetch(name) do
        fail(ArgumentError, "Unknown format: #{name}")
      end
    end

    # A Base64 implementation of SimplyAES::Format that emits
    # strings *without* newlines and can handle concatenated-b64 strings
    module Base64
      extend self
      require 'base64'
      include Format

      def load(formatted)
        # Because Base64 has 3:4 raw:formated ratio, it doesn't always break
        # cleanly on byte boundaries; add support for concatenated
        # iv+ciphertext encoded payloads
        formatted.scan(/[^=]+(?:=+|\Z)/m).map do |chunk|
          ::Base64.decode64(chunk)
        end.join
      end

      def dump(bytestring)
        ::Base64.encode64(bytestring).tr("\n", '')
      end
    end

    # A Hex implementation of SimplyAES::Format that emits
    # strings *without* newlines and can handle concatenated-hex strings
    module Hex
      extend self
      include Format

      def load(formatted)
        [formatted].pack('H*')
      end

      def dump(bytestring)
        bytestring.unpack('H*')[0]
      end
    end

    # The default implementation of SimplyAES::Format that reads and emits
    # unformatted byte strings.
    module Bytes
      extend self
      include Format

      def load(formatted)
        formatted.dup
      end

      def dump(bytestring)
        bytestring.dup
      end
    end
  end
end
