module Hakoy
  module FileAppender
    module Csv
      extend self

      module DuplicatesFilter
        class << self
          def call(file_path, rows_hash, uid_key)
            results = []

            rows_hash.each do |row_hash|
              is_duplicate = false

              CSV.foreach(file_path, headers: true) do |row|
                row_uid_key = row[uid_key] || Hakoy::RowNormalizer::GenerateUniqueId.(row.to_hash)
                is_duplicate = true if row_uid_key == row_hash[uid_key]
              end

              unless is_duplicate
                results << row_hash
              end
            end

            results
          end
        end
      end

      def call(file_path, rows_hash, opts={})
        uid_key      = opts.fetch(:uid_key) { 'uid' }
        keys_mapping = opts.fetch(:keys_mapping) # An array
        file_exists  = File.exists?(file_path)
        rows_hash    = Array.wrap(rows_hash)
        keys         = keys_mapping.keys
        header_keys  = keys_mapping.values

        return if rows_hash.empty?

        append_row_hash_values = -> (row_hash) do
          append_to_csv_file(file_path, row_hash.values_at(*header_keys))
        end

        if file_exists
          when_not_a_duplicate(file_path, rows_hash, uid_key, &append_row_hash_values)
        else
          # Add header for new file and no need to check duplicates
          header_hash = rows_hash[0].keys.map {|key| keys_mapping.key(key) }
          append_to_csv_file file_path, keys
          rows_hash.each(&append_row_hash_values)
        end
      end

      private

      def append_to_csv_file(file_path, *rows)
        CSV.open(file_path, 'a') do |to_file|
          rows.each {|r| to_file << r}
        end
      end

      def when_not_a_duplicate(file_path, rows_hash, uid_key, &block)
        unique_rows_hash = DuplicatesFilter.(file_path, rows_hash, uid_key)
        unique_rows_hash.each do |row_hash|
          block.call(row_hash)
        end
      end
    end
  end
end
