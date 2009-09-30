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

  def sort
    return sources if sorted
    preprocessor = JSDM::Preprocessor.new load_path, options
    self.sorted  = true
    self.sources = preprocessor.process
    sources
  end

  def concatenate(output_name, header = "")
    output_name = File.expand_path output_name
    output = File.open output_name, "w"
    sort.each do |source|
      h = header.sub /__FILE__/, "#{source}\n"
      data = File.new(source).read
      output.write(h + data)
      puts "Appended file: #{source}" if options[:verbose]
    end
    output.close
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
    options.select { |key, value| value }.each do |key, value|
      tmp.write("options('#{key.to_s}');\n")
    end
    sort.each do |source| 
      tmp.write "print('Processing #{source}...');\n"
      tmp.write "load('#{source}');\n"
    end
    tmp.flush
    system("js -f #{tmp.path} #{options[:output] ? '' : '&>/dev/null'}")
  end

  attr_accessor :load_path, :options, :sorted, :sources
end
