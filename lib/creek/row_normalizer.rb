module Creek
  class RowNormalizer
    MissingRequiredKeysError = Class.new(StandardError)

    def initialize(opts)
      @uid_key = opts.fetch(:uid_key)
      @required_keys = opts.fetch(:required_keys).dup.freeze
    end

    def normalize(hash)
      assert_has_required_keys!(hash, @required_keys)
      build_normalized_hash(hash)
    end
    alias_method :call, :normalize

    private

    def build_normalized_hash(hash)
      new_hash = hash.slice(*@required_keys)
      new_hash[@uid_key] = generate_unique_id(new_hash)
      new_hash
    end

    def generate_unique_id(hash)
      hash.values.map(&:to_s).join
    end

    def assert_has_required_keys!(hash, required_keys)
      required_keys.each do |k|
        hash.fetch(k) { fail MissingRequiredKeysError }
      end
    end
  end
end
