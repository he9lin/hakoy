# Hakoy

[![Code Climate](https://codeclimate.com/github/he9lin/hakoy.png)](https://codeclimate.com/github/he9lin/hakoy)

Parse and organize CSV data into timestamp-sliced directories.


## Usage

```ruby
conf = {
  db_dir:        'your file dir to store results',
  output_format: 'csv', # default
  timestamp_key: 'timestamp column index',
  required_keys: [
    customer:  24,
    product:   17,
    timestamp: 15,
    price:     18,
    quantity:  16,
    order_id:  0
  ]
}

Hakoy.('data/order.csv', conf)
```

It creates and organizes directories and files using timestamps. Below is a sample screenshot.

![screen shot 2014-06-12 at 12 13 34 pm](https://cloud.githubusercontent.com/assets/79277/3262506/0e4dc94c-f266-11e3-8974-db35186cbebd.png)

## TODO

* Better unique key generation algorithm. It is too primitive now.
