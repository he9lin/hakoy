require 'spec_helper'

describe Creek::FileAppender do
  before(:all) {
    @row = JSON.parse(File.read fixture_file('order.json'))
  }

  let(:row_hash)  { @row }
  let(:dir)       { File.join tmp_path, '2014/5' }
  let(:file)      { '28.txt' }
  let(:file_path) { File.join dir, file }

  after {
    FileUtils.remove_dir(dir, true)
  }

  describe 'plain text file' do
    before {
      options = { file_path: file_path, row_hash: row_hash }
      described_class.append(options)
    }

    it 'makes directory if not exist' do
      expect(File.directory?(dir)).to be_true
    end

    it 'accepts string as file_path' do
      another_file_path = File.join(dir, '30.txt').to_s
      options = { file_path: another_file_path, row_hash: row_hash }
      described_class.append(options)
      expect(File.readlines(another_file_path).first).to eq(row_hash.to_s + "\n")
    end

    it 'creates the file if not exist' do
      expect(File.exists?(file_path)).to be_true
    end

    it 'appends to specified file' do
      expect(File.readlines(file_path).first).to eq(row_hash.to_s + "\n")
    end

    it 'skips duplidates' do
      row_hash['order_id'] = '1002'
      options = { file_path: file_path, row_hash: row_hash }
      described_class.append(options)
      result = eval File.readlines(file_path).last
      expect(result['order_id']).to eq('1002')
    end
  end

  describe 'csv file' do
    it 'appends csv row' do
      file_path = File.join dir, '28.csv'
      options   = { file_path: file_path, row_hash: row_hash }

      described_class.append(options)
      header_row = CSV.parse(File.open(file_path, &:readline)).first
      expect(header_row).to eq(row_hash.keys)
    end
  end
end
