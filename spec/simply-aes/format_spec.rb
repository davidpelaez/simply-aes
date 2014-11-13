# encoding: BINARY (prevent string literals from being trans-coded to UTF-8)

require 'simply-aes/format'

shared_examples_for(SimplyAES::Format) do
  let(:format) { described_class } # e.g., described_module
  subject { format }
  it { is_expected.to respond_to :load }
  it { is_expected.to respond_to :dump }

  context '#load' do
    it 'loads the value' do
      expect(format.load(formatted)).to eq(bytestring)
    end
  end

  context '#dump' do
    it 'dumps the value' do
      expect(format.dump(bytestring)).to eq(formatted)
    end
  end

  context 'implementation selecting' do
    it 'can be loaded by name' do
      expect(SimplyAES::Format[short_name]).to eq format
    end
    it 'can be loaded when given explicitly' do
      expect(SimplyAES::Format[format]).to eq format
    end
  end
end

describe(SimplyAES::Format::Bytes) do
  let(:formatted) { "\xff\x1c\xae" }
  let(:bytestring) { "\xff\x1c\xae" }
  let(:short_name) { :bytes }
  it_should_behave_like(SimplyAES::Format)
end

describe(SimplyAES::Format::Base64) do
  let(:formatted) { '/xyu' }
  let(:bytestring) { "\xFF\x1C\xAE" }
  let(:short_name) { :base64 }
  it_should_behave_like(SimplyAES::Format)
end

describe(SimplyAES::Format::Hex) do
  let(:formatted) { 'ff1cae' }
  let(:bytestring) { "\xFF\x1C\xAE" }
  let(:short_name) { :hex }
  it_should_behave_like(SimplyAES::Format)
end
