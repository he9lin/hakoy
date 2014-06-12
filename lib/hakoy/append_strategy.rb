module Hakoy
  class AppendStrategy
    def append_row_to_file(file_path, row_hash)
      memory[file_path] << row_hash
    end

    def finalize!(uid_key)
      memory.each do |file_path, rows_hash|
        FileAppender.(file_path, rows_hash, uid_key:  uid_key)
      end
    end

    private

    def memory
      @_memory ||= Hash.new { |h, k| h[k] = [] }
    end
  end
end
