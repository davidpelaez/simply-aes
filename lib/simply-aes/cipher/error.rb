# encoding: utf-8

module SimplyAES
  # @see SimplyAES::Cipher
  class Cipher
    # SimplyAES::Cipher::Error is a wrapper for all
    # errors raised by SimplyAES::Cipher
    class Error < RuntimeError
      # Back-port Ruby 2.1's Exception#cause
      unless method_defined?(:cause)
        def initialize(*args)
          @cause = $! # rubocop:disable Style/SpecialGlobalVars
          super
        end
        attr_reader :cause
      end
    end

    LoadError = Class.new(Error)
    DumpError = Class.new(Error)
  end
end
