require_relative "creek/version"
require_relative "creek/ext/hash"
require_relative "creek/timestamp_path"
require_relative "creek/row_normalizer"
require_relative "creek/file_appender"

module Creek
  def self.call(file, conf)
    Proxy.new(conf).store(file)
  end

  class Proxy
    def initialize(conf)
      @timestamp_path = TimestampPath.new
      @row_normalizer = RowNormalizer.new(conf)
      @timestamp_key  = conf.fetch(:timestamp_key)
      @db_dir         = conf.fetch(:db_dir)
    end

    def store(file)
      CSV.foreach(file, headers: true) do |row|
        store_row(row.to_hash)
      end
    end

    def store_row(row_hash)
      path_opts = @timestamp_path.to_path(row_hash[@timestamp_key])
      path = File.join @db_dir, path_opts[:dir], "#{path_opts[:file]}.csv"
      row_hash = @row_normalizer.normalize(row_hash)
      FileAppender.append(file_path: path, row_hash: row_hash)
    end
  end
end
