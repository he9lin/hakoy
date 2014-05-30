require 'spec_helper'

describe Hakoy::TimestampPath do
  describe '#to_path' do
    let(:timestamp_str) {'2014-05-28 10:26:09 -0700'}

    context 'in 1 day' do
      it do
        result = described_class.new(unit: :day)
        expect(result.to_path(timestamp_str)).to \
          eq(dir: '2014/5', file: '28')
      end
    end

    context 'default day as unit' do
      it do
        result = described_class.new
        expect(result.to_path(timestamp_str)).to \
          eq(dir: '2014/5', file: '28')
      end
    end

    context 'in hours' do
      context 'with a 1 hour span' do
        it do
          result = described_class.new(unit: :hour, span: 1)
          expect(result.to_path(timestamp_str)).to \
            eq(dir: '2014/5/28', file: '10')
        end
      end

      context 'default 1 hour span' do
        it do
          result = described_class.new(unit: :hour)
          expect(result.to_path(timestamp_str)).to \
            eq(dir: '2014/5/28', file: '10')
        end
      end

      context 'with a 12 hours span' do
        it do
          result = described_class.new(unit: :hour, span: 12)
          expect(result.to_path(timestamp_str)).to \
            eq(dir: '2014/5/28', file: '00')
        end
      end
    end
  end
end
