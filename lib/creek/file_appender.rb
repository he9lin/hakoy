require 'fileutils'
require 'csv'

require_relative 'file_appender/txt'
require_relative 'file_appender/csv'

module Creek
  module FileAppender
    extend self

    def append(hash)
      file_path  = hash.fetch(:file_path)
      row_hash   = hash.fetch(:row_hash)
      dir        = File.dirname(file_path)

      extname  = find_extname(file_path)
      strategy = find_strategy(extname)

      ensure_dir_exist(dir)
      strategy.(file_path, row_hash)
    end

    private

    def find_extname(file_path)
      extname = File.extname(file_path)
      extname = '.txt' if extname == ''
      extname
    end

    def find_strategy(extname)
      appender_type = extname[1..-1].capitalize
      const_get appender_type
    end

    def ensure_dir_exist(dir)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end
  end
end
