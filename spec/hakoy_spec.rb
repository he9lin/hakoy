require 'spec_helper'

describe Hakoy do
  after do
    FileUtils.remove_dir(File.join(tmp_path, '2014'), true)
  end

  it 'stores csv rows in timestamp sliced directories' do
    conf = {
      timestamp_key: 15,
      db_dir: tmp_path,
      output_format: 'csv',
      required_keys_mapping: {
        customer:  24,
        product:   17,
        timestamp: 15,
        price:     18,
        quantity:  16,
        order_id:  0
      }
    }
    Hakoy.(fixture_file('orders.csv'), conf)

    file1 = File.join tmp_path, '2014/5/26.csv'
    file2 = File.join tmp_path, '2014/5/28.csv'

    [file1, file2].each do |file|
      expect(File.exist?(file)).to be_true
    end

    header = CSV.read(file1).first
    expected_header = conf[:required_keys_mapping].keys.map(&:to_s)
    expect(header).to match_array(expected_header)
  end
end
