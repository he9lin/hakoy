require 'spec_helper'

describe Creek do
  it 'stores csv rows in timestamp sliced directories' do
    conf = {
      timestamp_key: 'Created at',
      db_dir: tmp_path,
      output_format: 'csv',
      required_keys: [
        'Billing Name',
        'Lineitem name',
        'Created at',
        'Lineitem price',
        'Lineitem quantity',
        'Name' # order_id
      ]
    }
    Creek.(fixture_file('orders.csv'), conf)

    file1 = File.join tmp_path, '2014/5/26.csv'
    file2 = File.join tmp_path, '2014/5/28.csv'
    [file1, file2].each do |file|
      expect(File.exists?(file)).to be_true
    end

    FileUtils.remove_dir(File.join(tmp_path, '2014'), true)
  end
end
