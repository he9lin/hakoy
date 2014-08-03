module Hakoy
  class TimestampNormalizer
    attr_reader :key

    def initialize(opts)
      @key = opts.fetch(:key)
    end

    def call(hash)
      hash[key] = Chronic.parse(hash[key]).to_s
      hash
    end
  end
end
