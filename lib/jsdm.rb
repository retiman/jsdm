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

  attr_accessor :load_path, :options
end
