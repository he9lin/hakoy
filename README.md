# Creek: Process and manage CSV files data into timestamp-sliced directories.

## Basic features:

* Parse CSV files and store transactions/orders in timestamp-sliced directories.
* If there is a transaction id, then use it to filter out duplicates. If no
  transaction id, then generate a transaction id base on timestamp, customer_id,
  price, and product

## Inputs

* A CSV file or a directory of CSV files
* Configuration
  * `timestamp_key`
  * `uuid_key`
  * `uuid_hints`

## Outputs

Sample directory structure

```
- 2012
  - 10
    - 30
    - 31
  - 11
```
