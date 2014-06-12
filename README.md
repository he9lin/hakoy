# Hakoy

[![Code Climate](https://codeclimate.com/github/he9lin/hakoy.png)](https://codeclimate.com/github/he9lin/hakoy)

Parse and organize CSV data into timestamp-sliced directories.


## Usage

```ruby
conf = {
  db_dir:        'your file dir to store results',
  output_format: 'csv', # default
  timestamp_key: 'timestamp',
  required_keys: [
    'order_id',
    'customer_id',
    'product_id',
    'price',
    'timestamp'
  ]
}

Hakoy.('data/order.csv', conf)
```

## TODO

* Better unique key generation algorithm. It is too primitive now.
