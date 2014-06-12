module Hakoy
  module FileIterator
    extend self

    def call(file, opts={}, &block)
      extname = File.extname(file)
      iterator = opts.fetch(:iterator) { find_iterator(extname) }
      iterator.(file, &block)
    end

    private

    def find_iterator(extname)
      file_iterator = extname[1..-1].capitalize
      const_get file_iterator
    end
  end
end

require_relative 'file_iterator/csv'
