class Hash
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  def except(*keys)
    dup.except!(*keys)
  end

  def slice(*keys)
    keys.each_with_object(self.class.new) do |k, hash|
      hash[k] = self[k] if has_key?(k)
    end
  end
end
