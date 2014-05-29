module Creek
  class RowNormalizer
    MissingRequiredKeysError = Class.new(StandardError)

    def initialize(opts)
      @required_keys = opts.fetch(:required_keys).dup.freeze
    end

    def normalize(hash)
      assert_has_required_keys!(hash, @required_keys)
      build_normalized_hash(hash)
    end
    alias :call :normalize

    private

    def build_normalized_hash(hash)
      new_hash = hash.slice *@required_keys
      new_hash['id'] = generate_unique_id(new_hash)
      new_hash
    end

    def generate_unique_id(hash)
      hash.values.map(&:to_s).join
    end

    def assert_has_required_keys!(hash, required_keys)
      required_keys.each do |k|
        hash.fetch(k) { raise MissingRequiredKeysError }
      end
    end
  end
end
