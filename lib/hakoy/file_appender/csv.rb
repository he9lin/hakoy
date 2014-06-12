module Hakoy
  module FileAppender
    module Csv
      extend self

      def call(file_path, rows_hash, opts={})
        uid_key     = opts.fetch(:uid_key) { 'id' }
        file_exists = File.exists?(file_path)
        rows_hash   = Array.wrap(rows_hash)

        return if rows_hash.empty?

        header_hash = rows_hash[0].keys

        CSV.open(file_path, 'a') do |to_file|
          append_row_hash_values = -> (row_hash) do
            append_to_csv_file(to_file, row_hash.values)
          end

          if file_exists
            when_not_a_duplicate(file_path, rows_hash, uid_key, &append_row_hash_values)
          else
            # Add header for new file and no need to check duplicates
            append_to_csv_file to_file, header_hash
            rows_hash.each(&append_row_hash_values)
          end
        end
      end

      private

      def append_to_csv_file(to_file, *rows)
        rows.each {|r| to_file << r}
      end

      def when_not_a_duplicate(file_path, rows_hash, uid_key, &block)
        duplicates = Hakoy::CsvDuplicateFinder.(file_path, rows_hash, uid_key)
        duplicate_keys = duplicates.map {|h| h[uid_key]}

        rows_hash.each do |row_hash|
          block.call(row_hash) unless duplicate_keys.include?(row_hash[uid_key])
        end
      end
    end
  end
end
