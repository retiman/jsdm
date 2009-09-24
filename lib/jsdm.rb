require 'jsdm/preprocessor'

class Jsdm
  def initialize(source_root)
    self.source_root = source_root
  end

  def sort
    preprocessor = JSDM::Preprocessor.new(source_root)
    preprocessor.process
  end

  attr_accessor :source_root
  private :source_root=
end
