require 'jsdm/preprocessor'
require 'open3'
require 'pp'

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
    self.sources = preprocessor.process
    self.sorted  = true
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

  def sequence(bin)
    buffer = { :errors => "", :output => "" }
    Open3.popen3(bin) do |stdin, stdout, stderr|
      sort.each do |source|
        [stdin, stdout, stderr].each { |stream| stream.sync = true }
        stdin.puts(')print("hello, world!");')
        stdin.close
        IO.select([stdout, stderr], [], [], 2)
        stdout.readpartial(1024, buffer[:output]) rescue nil
        stderr.readpartial(1024, buffer[:errors]) rescue nil
        puts "ERROR: #{buffer[:errors]}"
      end
    end
    #pp buffer
  end

  attr_accessor :load_path, :options, :sorted, :sources
end
