require 'fileutils'
require 'csv'

require_relative "hakoy/version"
require_relative "hakoy/ext/hash"
require_relative "hakoy/ext/array"
require_relative "hakoy/file_iterator"
require_relative "hakoy/timestamp_path"
require_relative "hakoy/row_normalizer"
require_relative "hakoy/file_appender"
require_relative "hakoy/csv_duplicate_finder"

module Hakoy
  def self.call(file, conf)
    Proxy.new(conf).store(file)
  end

  class Proxy
    DEFAULT_OUTPUT_FORMAT = 'csv'
    DEFAULT_UID_KEY       = 'id'

    def initialize(conf)
      @timestamp_key  = conf.fetch(:timestamp_key)
      @db_dir         = conf.fetch(:db_dir)
      @output_format  = conf.fetch(:output_format) { DEFAULT_OUTPUT_FORMAT }
      @uid_key        = conf.fetch(:uid_key) { DEFAULT_UID_KEY }
      @strategies     = conf.fetch(:strategies) { Hash.new }
      required_keys   = conf.fetch(:required_keys)

      @timestamp_path = TimestampPath.new
      @row_normalizer = RowNormalizer.new(
        required_keys: required_keys, uid_key: @uid_key)
    end

    def store(file)
      FileIterator.(file) { |row_hash| store_row(row_hash) }
      finalize_store!
    end

    private

    def store_row(row_hash)
      file_path            = build_file_path(row_hash)
      normalized_row_hash  = normalize_row_hash(row_hash)

      append_file(file_path, normalized_row_hash)
    end

    def build_file_path(row_hash)
      path_opts = @timestamp_path.to_path(row_hash[@timestamp_key])
      File.join \
        @db_dir, path_opts[:dir], "#{path_opts[:file]}.#{@output_format}"
    end

    def normalize_row_hash(row_hash)
      @row_normalizer.normalize(row_hash)
    end

    def append_file(file_path, row_hash)
      memory[file_path] << row_hash
    end

    def memory
      @_memory ||= Hash.new { |h, k| h[k] = [] }
    end

    def finalize_store!
      memory.each do |file_path, rows_hash|
        FileAppender.(file_path, rows_hash,
                      strategy: @strategies[:append_file],
                      uid_key:  @uid_key)
      end
    end
  end
end
