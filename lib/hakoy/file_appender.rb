module Hakoy
  module FileAppender
    extend self

    def append(file_path, row_hash, opts={})
      dir     = File.dirname(file_path)
      extname = File.extname(file_path)

      ensure_dir_exist(dir)

      strategy = find_strategy(extname)
      strategy.(file_path, row_hash, opts)
    end
    alias :call :append

    private

    def find_strategy(extname)
      appender_type = extname[1..-1].capitalize
      const_get appender_type
    end

    def ensure_dir_exist(dir)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end
  end
end

require_relative 'file_appender/csv'
