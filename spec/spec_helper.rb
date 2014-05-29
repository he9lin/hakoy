$LOAD_PATH.unshift File.expand_path(File.join File.dirname(__FILE__), '..', 'lib')

require 'creek'
require 'pathname'
require 'json'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  def fixture_path
    File.expand_path(File.join File.dirname(__FILE__), 'fixtures')
  end

  def fixture_file(filename)
    File.join(fixture_path, filename)
  end

  def tmp_path
    File.expand_path(File.join File.dirname(__FILE__), 'tmp')
  end
end
