require 'jsdm/preprocessor'

class JSDM
  def initialize(load_path = [], options = {})
    defaults = {
      :verbose   => false,
      :extension => "js",
    }
    self.load_path = load_path
    self.options = defaults.merge! options
  end

  def sort
    preprocessor = JSDM::Preprocessor.new(load_path, options)
    preprocessor.process
  end

  def concatenate(output_name, header = "")
    output_name = File.expand_path output_name
    output = File.open output_name, "w"
    sort.each do |source|
      h = header.sub /__FILE__/, "#{source}\n"
      data = File.new(source).read
      output.write(h + data)
    end
    output.close
  end

  attr_accessor :load_path, :options
end
