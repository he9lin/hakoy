require 'spec_helper'

describe Creek::RowNormalizer do
  describe '#normalize' do
    before(:all) do
      @row = JSON.parse(File.read fixture_file('order.json'))
    end

    let(:input)  { @row }

    let(:conf) do
      {
        uid_key: 'id',
        required_keys: \
          %w(order_id product customer price timestamp quantity)
      }
    end

    before do
      @row_normalizer = described_class.new(conf)
    end

    it 'returns a hash containing required keys' do
      result = @row_normalizer.normalize(input)
      expect(result).to_not have_key('type')
    end

    it 'generates a unique id based on required keys' do
      result  = @row_normalizer.normalize(input)
      expect(result['id']).to_not be_nil

      result2 = @row_normalizer.normalize(input)
      expect(result['id']).to eq(result['id'])

      input['order_id'] = '1002'
      result3 = @row_normalizer.normalize(input)
      expect(result3['id']).to_not eq(result['id'])
    end

    it 'raises error if any of the required keys not found' do
      input.delete('product')
      expect { @row_normalizer.normalize(input) }.to \
        raise_error(described_class::MissingRequiredKeysError)
    end
  end
end
