module JSDM
  class Preprocessor
    attr_reader :source_root

    def initialize(source_root)
      self.source_root = source_root
      self.nodes = []
      self.arcs = []
    end

    def parse_include(file)
      pattern = /^\s*\/\/\s*#include\s*/
      File.new(file).
           readlines.
           take_while { |line| line =~ pattern }.
           map { |line| line.sub(pattern, "").strip }
    end

    def resolve_include(entries)
      sources = []
      entries.each do |entry|
        entry.split(",").each do |file_pattern|
          sources += Dir["#{source_root}/#{file_pattern.strip}"]
        end
      end
      sources
    end

    private
    attr_writer :source_root
    attr_accessor :nodes
    attr_accessor :arcs
  end
end
