module Hakoy
  module FileAppender
    module Csv
      extend self

      def call(file_path, row_hash, opts={})
        uid_key = opts.fetch(:uid_key) { 'id' }

        file_exists = File.exists?(file_path)

        if file_exists
          when_not_a_duplicate(file_path, row_hash, uid_key) do
            append_to_csv_file(file_path, row_hash.values)
          end
        else
          append_to_csv_file(file_path, row_hash.keys, row_hash.values)
        end
      end

      private

      def append_to_csv_file(file_path, *rows)
        CSV.open(file_path, 'a') do |to_file|
          rows.each {|r| to_file << r}
        end
      end

      def when_not_a_duplicate(file_path, row_hash, uid_key, &block)
        is_duplicate = false
        check_duplidate = -> (row) {
          is_duplicate = true if row[uid_key] == row_hash[uid_key]
        }
        CSV.foreach(file_path, headers: true, &check_duplidate)
        block.call unless is_duplicate
      end
    end
  end
end
