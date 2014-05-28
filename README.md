# Creek: Process and manage CSV files data into timestamp-sliced directories.

## Basic features:

* Parse CSV files and store transactions/orders in timestamp-sliced directories.
* If there is a transaction id, then use it to filter out duplicates. If no
  transaction id, then generate a transaction id base on timestamp, customer_id,
  price, and product

## Inputs

* A CSV file or a directory of CSV files
* Configuration
  - `timestamp_key`
  - `uuid_key`
  - `uuid_hints`
  - `source`

## Outputs

Sample directory structure

```
- 2012
  - 10
    - 30.csv
    - 31.csv
  - 11
```

## API

```ruby
conf = {
  required_cols: [...]
  input_file: path_to_csv_file
  output_dir: "/tmp",
  output_path: "%Y/%m/%D"
  source: "local"
  timestamp_col_name: "Date time"
}
creek = Creek.new(conf)
creek.()
```

## Tasks, Roles

Each row run: fetch timestamp and return the directory/file to store/append for
this row.

```ruby
def input_split(row)
  TimestampToDir.(row['timestamp'], conf)
end
# => { dir: '/tmp/2014/5', file: '28.csv' }

def mkdir_path
  # 1. Create a directory base on the result of input_split
end

def generate_output(csv_row_as_hash)
  # 1. Genarate uuid if not present
  # 2. Gather fields from required cols
  # 3. Create a CSV row hash
end

def append_output
  # 1. Skip duplication in the destination file to be appended
  # 2. Append to destination file
end
```
