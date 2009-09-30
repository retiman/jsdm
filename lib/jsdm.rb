require 'jsdm/preprocessor'
require 'jsdm/spidermonkey'

# todo: jsdm should coordinate the preprocessor and dependency manager
# the preprocessor should only give a list of source => deps and
# let the dependency manager figure it out
class JSDM
  def initialize(load_path = [], options = {})
    defaults = {
      :verbose   => false,
      :extension => "js",
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

  def concatenate(output, header = "")
    File.open(output, "w") do |file|
      sorted_sources.each do |source|
        file.puts header.sub(/__FILE__/, source)
        file.puts File.new(source).read
        puts "Appended file: #{source}" if options[:verbose]
      end
    end
  end

  def js_check(options = {})
    Spidermonkey.new(sorted_sources, options).check
  end

  attr_accessor :load_path, :options, :sorted, :sources, :preprocessor
end
