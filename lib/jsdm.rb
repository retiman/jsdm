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
      yield output_name
    end
    output.close
  end

  def js_check(options = {})
    tmp = Tempfile.new "jsdm"
    sort.each do |source| 
      tmp.write "print('Processing #{source}:');\n"
      tmp.write "load('#{source}');\n"
    end
    tmp.flush
    system("js -f #{tmp.path}")
  end

  attr_accessor :load_path, :options, :sorted, :sources
end
