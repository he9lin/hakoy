module Creek
  module FileAppender
    module Txt
      extend self

      def call(file_path, row_hash)
        File.open(file_path, 'a') do |to_file|
          to_file << row_hash.to_s << "\n"
        end
      end
    end
  end
end
