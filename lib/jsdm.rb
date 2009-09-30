require 'jsdm/preprocessor'
require 'tempfile'

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
    defaults = {
      :strict => false,
      :werror => false,
      :atline => false,
      :xml    => false,
      :output => true
    }
    options = defaults.merge! options
    puts "Checking Javascript with Spidermonkey" if options[:verbose]
    tmp = Tempfile.new "jsdm"
    options.select { |k, v| v }.
            each   { |k, v| tmp.puts "options('#{k.to_s}');" }
    sorted_sources.each do |source| 
      tmp.puts "print('Processing #{source}...');"
      tmp.puts "load('#{source}');"
    end
    tmp.flush
    system "js -f #{tmp.path} #{options[:output] ? '' : '&>/dev/null'}"
  end

  attr_accessor :load_path, :options, :sorted, :sources
end
