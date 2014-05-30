module Hakoy
  module FileIterator
    module Csv
      extend self

      def call(file, &block)
        CSV.foreach(file, headers: true) do |row|
          block.call(row.to_hash)
        end
      end
    end
  end
end
