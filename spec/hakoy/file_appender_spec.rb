require 'spec_helper'

describe Hakoy::FileAppender do
  before(:all) {
    @row = JSON.parse(File.read fixture_file('order.json'))
  }

  def parse_csv_file(file)
    CSV.read(file)
  end

  let(:row_hash)  { @row }
  let(:dir)       { File.join tmp_path, '2014/5' }
  let(:file)      { '28.csv' }
  let(:file_path) { File.join dir, file }
  let(:uid_key)   { 'order_id' }
  let(:mapping)   do
    {
      customer:  'customer',
      product:   'product',
      timestamp: 'timestamp',
      price:     'price',
      quantity:  'quantity',
      order_id:  'order_id'
    }
  end

  after { FileUtils.remove_dir(dir, true) }

  describe 'for csv file format' do

    before { described_class.(file_path, row_hash, keys_mapping: mapping) }

    it 'makes directory if not exist' do
      expect(File.directory?(dir)).to be_true
    end

    it 'creates the file if not exist' do
      expect(File.exist?(file_path)).to be_true
    end

    it 'write header row to the file' do
      header_row = parse_csv_file(file_path)[0]
      expect(header_row).to \
        eq(%w(customer product timestamp price quantity order_id))
    end

    it 'write row to the file' do
      row = parse_csv_file(file_path)[1]
      expect(row).to eq(row_hash.values_at(*mapping.values))
    end

    it 'accepts string as :file_path param' do
      another_file_path = File.join(dir, '30.csv').to_s

      described_class.(another_file_path, row_hash, keys_mapping: mapping)
      expect(File.exists?(another_file_path)).to be_true
    end

    it 'appends to the file' do
      row_hash[uid_key] = '1002'

      described_class.(file_path, row_hash, uid_key: uid_key, keys_mapping: mapping)
      result = File.readlines(file_path).last
      expect(result).to include('1002')
    end

    it 'skips duplicates' do
      described_class.(file_path, row_hash, uid_key: uid_key, keys_mapping: mapping)
      expect(File.readlines(file_path).length).to eq(2)
    end
  end
end
