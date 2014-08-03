require 'fileutils'
require 'csv'
require 'chronic'

require_relative "hakoy/version"
require_relative "hakoy/ext/hash"
require_relative "hakoy/ext/array"
require_relative "hakoy/append_strategy"
require_relative "hakoy/file_iterator"
require_relative "hakoy/timestamp_path"
require_relative "hakoy/timestamp_normalizer"
require_relative "hakoy/row_normalizer"
require_relative "hakoy/file_appender"

module Hakoy
  def self.call(file, conf)
    Proxy.new(conf).store(file)
  end

  class Proxy
    DEFAULT_OUTPUT_FORMAT = 'csv'
    DEFAULT_UID_KEY       = 'uid'

    def initialize(conf)
      @timestamp_key         = conf.fetch(:timestamp_key)
      @db_dir                = conf.fetch(:db_dir)
      @output_format         = conf.fetch(:output_format)   { DEFAULT_OUTPUT_FORMAT }
      @uid_key               = conf.fetch(:uid_key)         { DEFAULT_UID_KEY       }
      @file_iterator         = conf.fetch(:file_iterator)   { FileIterator          }
      @append_strategy       = conf.fetch(:append_strategy) { AppendStrategy.new    }
      @required_keys_mapping = conf.fetch(:required_keys_mapping)
      @timestamp_path        = TimestampPath.new
      @row_normalizer        = RowNormalizer.new(
        required_keys: @required_keys_mapping.values, uid_key: @uid_key
      )
      @timestamp_normalizer  = TimestampNormalizer.new(
        key: @timestamp_key
      )
    end

    def store(file)
      @file_iterator.(file) { |row_hash| store_row(row_hash) }
      finalize_store!
    end

    private

    def store_row(row_hash)
      row_hash            = normalize_timestamp(row_hash)
      file_path           = build_file_path(row_hash)
      normalized_row_hash = normalize_row_hash(row_hash)

      append_row_to_file(file_path, normalized_row_hash)
    end

    def build_file_path(row_hash)
      path_opts = @timestamp_path.to_path(row_hash[@timestamp_key])
      File.join \
        @db_dir, path_opts[:dir], "#{path_opts[:file]}.#{@output_format}"
    end

    def normalize_row_hash(row_hash)
      @row_normalizer.normalize(row_hash)
    end

    def normalize_timestamp(row_hash)
      @timestamp_normalizer.(row_hash)
    end

    def append_row_to_file(file_path, row_hash)
      @append_strategy.append_row_to_file file_path, row_hash
    end

    def finalize_store!
      @append_strategy.finalize! \
        uid_key:      DEFAULT_UID_KEY,
        keys_mapping: @required_keys_mapping
    end
  end
end
