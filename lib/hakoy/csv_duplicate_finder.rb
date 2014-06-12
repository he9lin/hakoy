module Hakoy
  module CsvDuplicateFinder
    extend self

    def call(file_path, rows_hash, uid_key)
      duplicate_rows = []
      check_duplidate = -> (row) do
        rows_hash.each do |row_hash|
          if row[uid_key] == row_hash[uid_key]
            duplicate_rows << row_hash
          end
        end
      end
      CSV.foreach(file_path, headers: true, &check_duplidate)
      duplicate_rows
    end
  end
end
