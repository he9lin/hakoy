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
  class << self
    def call(file, conf)
      Proxy.new(file, conf).store
    end

    def configure(&block)
      instance_eval(&block)
    end

    def root_dir(dir=nil)
      if dir
        @root_dir = dir
      else
        @root_dir
      end
    end
  end

  class Proxy
    DEFAULT_OUTPUT_FORMAT = 'csv'
    DEFAULT_UID_KEY       = 'uid'

    attr_reader :file, :required_keys, :timestamp_key

    def initialize(file, conf)
      raise 'Missing Hakoy.root_dir config' unless Hakoy.root_dir

      @file                  = file
      @db_dir                = File.join(Hakoy.root_dir, conf.fetch(:db_id))
      @output_format         = conf.fetch(:output_format)   { DEFAULT_OUTPUT_FORMAT }
      @uid_key               = conf.fetch(:uid_key)         { DEFAULT_UID_KEY       }
      @file_iterator         = conf.fetch(:file_iterator)   { FileIterator          }
      @append_strategy       = conf.fetch(:append_strategy) { AppendStrategy.new    }
      required_keys_mapping  = conf.fetch(:required_keys_mapping)
      timestamp_key          = conf.fetch(:timestamp_key)
      headers                = find_headers(file)
      @required_keys         = find_required_keys(headers, required_keys_mapping)
      @timestamp_key         = headers[timestamp_key]
      @timestamp_path        = TimestampPath.new
      @timestamp_normalizer  = TimestampNormalizer.new(key: @timestamp_key)
      @row_normalizer        = RowNormalizer.new \
                                 uid_key: @uid_key,
                                 required_keys: @required_keys.values
    end

    def store
      @file_iterator.(file) do |row_hash|
        store_row(row_hash)
      end

      finalize_store!
    end

    private

    # We are assuming we deal with CSV files only.
    def find_headers(file)
      csv_reader = CSV.new(File.open(file, 'r')).lazy
      csv_reader.take(1).force[0]
    end

    def find_required_keys(headers, required_keys_mapping)
      {}.tap do |hash|
        required_keys_mapping.each do |k, v|
          hash[k] = headers[v]
        end
      end
    end

    def store_row(row_hash)
      row_hash            = normalize_timestamp(row_hash)
      file_path           = build_file_path(row_hash)
      normalized_row_hash = normalize_row_hash(row_hash)

      append_row_to_file(file_path, normalized_row_hash)
    end

    def build_file_path(row_hash)
      path_opts = @timestamp_path.to_path(row_hash[timestamp_key])
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
        keys_mapping: required_keys
    end
  end
end
