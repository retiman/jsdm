require 'jsdm/preprocessor'
require 'jsdm/spidermonkey'

# todo: jsdm should coordinate the preprocessor and dependency manager
# the preprocessor should only give a list of source => deps and
# let the dependency manager figure it out
class JSDM
  def initialize(load_path = [], options = {})
    defaults = {
      :verbose    => false,
      :extension  => "js",
      :randomize  => false
    }
    self.options      = defaults.merge! options
    self.load_path    = load_path
    self.sorted       = false
    self.sources      = []
    self.preprocessor = JSDM::Preprocessor.new load_path, options
  end

  def sorted_sources
    return sources if sorted
    self.sorted  = true
    self.sources = preprocessor.process
    sources
  end

  # todo: let jsdm reference the dependency manager and make it do this
  def dependencies
    output = []
    sorted_sources.each do |source|
      deps = preprocessor.manager.
                          dependencies.
                          select { |entry| entry.last == source }
      output << [source, deps]
    end
    output
  end

  def concatenate(output_name, files = sorted_sources)
    File.open(output_name, "w") do |output|
      files.each do |file|
        output.puts "// #{file}:"
        output.puts File.new(file).read
        puts "Appended file: #{file}" if options[:verbose]
      end
    end
  end

  def js_check(files = sorted_sources, options = {})
    Spidermonkey.new(files, options).check
  end

  attr_accessor :load_path, :options, :sorted, :sources, :preprocessor
end
