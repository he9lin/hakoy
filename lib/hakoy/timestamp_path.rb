require 'time'

module Hakoy
  class TimestampPath
    DIR_PARTS_FOR = {
      day:  %w(year month),
      hour: %w(year month day)
    }

    TWO_DIGITS_FORMAT = '%02d'

    def initialize(opts={})
      unit = opts.fetch(:unit) { :day }
      span = opts.fetch(:span) { 1 }

      @dir_strategy  = -> (t) do
        DIR_PARTS_FOR[unit].map { |m| t.send(m) }.join('/')
      end

      @file_strategy = -> (t) do
        TWO_DIGITS_FORMAT % (t.send(unit) / span).to_i
      end
    end

    def to_path(timestamp_str)
      build_path Time.parse(timestamp_str)
    end
    alias_method :call, :to_path

    private

    def build_path(time)
      {
        dir:  @dir_strategy.(time),
        file: @file_strategy.(time)
      }
    end
  end
end
