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
      expect(File.exist?(file)).to be_true
    end

    FileUtils.remove_dir(File.join(tmp_path, '2014'), true)
  end

  it 'stores avro records in timestamp sliced directories', focus: true do
    conf = {
      timestamp_key: 'Created at',
      db_dir: tmp_path,
      output_format: 'avro',
      required_keys: [
        'Billing Name',
        'Lineitem name',
        'Created at',
        'Lineitem price',
        'Lineitem quantity',
        'Name' # order_id
      ]
    }
    require 'avro'

    write = -> {
      SCHEMA = <<-JSON
{ "type": "record",
  "name": "User",
  "fields" : [
    {"name": "Billing Name", "type": "string"},
    {"name": "Lineitem name", "type": "string"},
    {"name": "Lineitem price", "type": "string"},
    {"name": "Created at", "type": "string"},
    {"name": "Lineitem quantity", "type": "int"},
    {"name": "Name", "type": "string"}
  ]}
JSON

      file = File.open('data.avr', 'wb')
      schema = Avro::Schema.parse(SCHEMA)
      writer = Avro::IO::DatumWriter.new(schema)
      dw = Avro::DataFile::Writer.new(file, writer, schema)
      dw << {"Billing Name"=>"Lin He", "Lineitem name"=>"Product D", "Created at"=>"2014-05-28 11:49:25 -0400", "Lineitem price"=>"19.99", "Lineitem quantity"=>1, "Name"=>"#1002"}
      dw << {"Billing Name"=>"Lin He", "Lineitem name"=>"Product B", "Created at"=>"2014-05-28 11:49:25 -0400", "Lineitem price"=>"0.00", "Lineitem quantity"=>1, "Name"=>"#1002"}
      dw << {"Billing Name"=>"Lin He", "Lineitem name"=>"Product C", "Created at"=>"2014-05-28 11:49:25 -0400", "Lineitem price"=>"0.00", "Lineitem quantity"=>2, "Name"=>"#1002"}
      dw << {"Billing Name"=>"Lin He", "Lineitem name"=>"Product B", "Created at"=>"2014-05-26 15:27:46 -0400", "Lineitem price"=>"0.00", "Lineitem quantity"=>1, "Name"=>"#1001"}
      dw << {"Billing Name"=>"Lin He", "Lineitem name"=>"Product C", "Created at"=>"2014-05-26 15:27:46 -0400", "Lineitem price"=>"0.00", "Lineitem quantity"=>2, "Name"=>"#1001"}
      dw.close
    }

    write.()

    read = -> {
      # read all data from avro file
      file = File.open('data.avr', 'r+')
      dr = Avro::DataFile::Reader.new(file, Avro::IO::DatumReader.new)
      dr.each { |record| p record }

      # extract the username only from the avro serialized file
      READER_SCHEMA = <<-JSON
{ "type": "record",
  "name": "User",
  "fields" : [
    {"name": "Billing Name", "type": "string"},
    {"name": "Lineitem name", "type": "string"},
    {"name": "Lineitem price", "type": "string"},
    {"name": "Created at", "type": "string"},
    {"name": "Lineitem quantity", "type": "int"},
    {"name": "Name", "type": "string"}
  ]}
JSON

      reader = Avro::IO::DatumReader.new(nil, Avro::Schema.parse(READER_SCHEMA))
      dr = Avro::DataFile::Reader.new(file, reader)
      dr.each { |record| p record }
    }

    read.()

    # CSV.read(fixture_file('orders.csv'), headers: true).each do |row|
    #   p row.to_hash.slice(*conf[:required_keys])
    # end

    # Creek.(fixture_file('orders.csv'), conf)

    # file1 = File.join tmp_path, '2014/5/26.csv'
    # file2 = File.join tmp_path, '2014/5/28.csv'
    # [file1, file2].each do |file|
    #   expect(File.exist?(file)).to be_true
    # end

    # FileUtils.remove_dir(File.join(tmp_path, '2014'), true)
  end
end
