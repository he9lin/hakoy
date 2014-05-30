require 'fileutils'
require 'csv'

require_relative "hakoy/version"
require_relative "hakoy/ext/hash"
require_relative "hakoy/file_iterator"
require_relative "hakoy/timestamp_path"
require_relative "hakoy/row_normalizer"
require_relative "hakoy/file_appender"

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
      required_keys   = conf.fetch(:required_keys)

      @timestamp_path = TimestampPath.new
      @row_normalizer = RowNormalizer.new(
        required_keys: required_keys, uid_key: @uid_key)
    end

    def store(file)
      FileIterator.(file) do |row_hash|
        store_row(row_hash)
      end
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
      FileAppender.(file_path, row_hash, uid_key: @uid_key)
    end
  end
end
