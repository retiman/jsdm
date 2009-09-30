require 'jsdm/preprocessor'
require 'jsdm/spidermonkey'

class JSDM
  def initialize(load_path = [], options = {})
    defaults = {
      :verbose   => false,
      :extension => "js",
    }
    self.options   = defaults.merge! options
    self.load_path = load_path
    self.sorted    = false
    self.sources   = []
  end

  def sorted_sources
    return sources if sorted
    preprocessor = JSDM::Preprocessor.new load_path, options
    self.sorted  = true
    self.sources = preprocessor.process
    sources
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

  attr_accessor :load_path, :options, :sorted, :sources
end
