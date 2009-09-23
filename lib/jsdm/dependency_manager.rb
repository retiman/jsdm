module JSDM
  class DependencyManager
    def initialize(source_root)
      self.source_root = source_root
      self.sources = []
      self.dependencies = []
    end

    def add_dependencies(source, includes)
      resolve_dependencies(includes).each do |dep|
        dependencies << [source, dep]
      end
    end

    def process
      # maybe add a warning about this later?
      sources = sources.uniq.select { |s| !s.empty? }
      dependencies = dependencies.uniq.select { |s| s.empty? || s.first == s.last }
      graph = DirectedGraph.new(sources, dependencies)
    end

    private
    attr_accessor :source_root
    attr_accessor :sources
    attr_accessor :dependencies

    def resolve_dependencies(includes)
      deps = []
      includes.each do |inc|
        inc.split(",").each do |entry|
          deps += Dir["#{source_root}/#{entry.strip}"]
        end
      end
      deps
    end
  end
end
