module Creek
  module FileAppender
    module Csv
      extend self

      def call(file_path, row_hash)
        file_exists = File.exists?(file_path)

        CSV.open(file_path, 'a') do |to_file|
          to_file << row_hash.keys unless file_exists
          to_file << row_hash.values
        end
      end
    end
  end
end
