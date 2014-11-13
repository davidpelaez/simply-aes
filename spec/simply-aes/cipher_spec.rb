# encoding: BINARY (prevent string literals from being trans-coded to UTF-8)

require 'simply-aes/cipher'

describe(SimplyAES::Cipher) do
  # default keys
  let(:key_hex) do
    'c3e6e6bbca5846ba4c1a4dd1953ccdc8a4e3fb0bfde7df8673de4f4f920e8df2'
  end
  let(:key) { SimplyAES::Format::Hex.load(key_hex) }

  context '#key' do
    context 'when initialised with a key' do
      let(:cipher) { described_class.new(key_hex, format: :hex) }

      subject { cipher }

      it 'returns that key' do
        expect(cipher.key).to eq(key_hex)
      end
      context('when a format is given') do
        it 'formats the key' do
          expect(cipher.key(format: :bytes)).to eq(key)
        end
      end
    end

    context 'when initialised without a key' do
      let(:cipher) { described_class.new(format: :hex) }
      it 'returns a securely-generated key' do
        expect(cipher.key).to match(/[0-9a-f]{64}/)
      end
      it 'memoizes the securely-generated key' do
        expect(cipher.key).to eq(cipher.key)
      end
    end
  end

  context '#dump' do
    let(:cipher) { described_class.new(key_hex, format: :hex) }

    # in order to make the output predictable, we need to use our own IV
    context 'when an initialisation vector is given' do
      let(:iv_hex) { 'babad50bea6035da71e9a0e076076860' }
      let(:iv) { SimplyAES::Format::Hex.load(iv_hex) }
      let(:decrypted) { 'Hello, World!' }
      let(:result) { cipher.dump(decrypted, iv: iv, format: :bytes) }

      context 'the encrypted value' do
        subject { result }
        it 'is prefixed by the IV' do
          expect(result).to start_with(iv)
        end
        it 'is longer than the IV' do
          expect(result.size).to be > (iv.size)
        end
        it 'matches the known value for the given key/iv pair' do
          expect(result).to eq(
            "\xBA\xBA\xD5\v\xEA`5\xDAq\xE9\xA0\xE0v\ah`\xE8\xCB\xF7+q\xB6" \
            "\xA5\xF5\xCC\xAD\xB7\xEB\xA8\xB5s\xCD")
        end
      end
    end

    context 'dumping the same value multiple times' do
      let(:decrypted) { 'Hello, World!' }

      it 'emits different results, with different IVs' do
        first  = cipher.dump(decrypted, format: :bytes)
        second = cipher.dump(decrypted, format: :bytes)

        # @todo: better quantify "different"
        expect(first).to_not eq(second)
      end
    end
  end

  context '#load' do
    let(:cipher) { described_class.new(key_hex, format: :hex) }
    let(:decrypted) { 'Hello, World!' }
    let(:encrypted) do
      "\xBA\xBA\xD5\v\xEA`5\xDAq\xE9\xA0\xE0v\ah`\xE8\xCB\xF7+q\xB6" \
      "\xA5\xF5\xCC\xAD\xB7\xEB\xA8\xB5s\xCD"
    end

    context 'when given a value that had been encrypted with the same key' do
      it 'decrypts the value' do
        expect(cipher.load(encrypted, format: :bytes)).to eq(decrypted)
      end
    end
    context 'when given a value that was NOT encrypted with the same key' do
      let(:alternate_cipher) { SimplyAES::Cipher.new(format: :bytes) }
      let(:alternate_encrypted) { alternate_cipher.dump(decrypted) }
      it 'raises a SimplyAES::Cipher::LoadError' do
        expect do
          cipher.load(alternate_encrypted, format: :bytes)
        end.to raise_exception(SimplyAES::Cipher::LoadError)
      end
    end
  end
end
