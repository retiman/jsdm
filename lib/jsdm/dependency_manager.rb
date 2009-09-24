module JSDM
  class DependencyManager
    def initialize(source_root)
      self.source_root = source_root
      self.sources = []
      self.dependencies = []
    end

    def add_dependencies(source, includes)
      resolve_dependencies(includes).each do |dep|
        # make an arc from dep to source
        # in a dfs, dep will be visited before source
        dependencies << [dep, source]
      end
    end

    def resolve_dependencies(entries)
      entries.map { |entry| Dir["#{source_root}/#{entry.strip}"] }.flatten
    end

    def process
      # maybe add a warning about these filters later?
      # make sure the user knows that some files didn't make the cut
      self.sources = sources.uniq.select { |s| !s.empty? }
      self.dependencies = dependencies.uniq.select { |s| s.empty? || s.first == s.last }
      DirectedGraph.new(sources, dependencies)
    end

    private
    attr_accessor :source_root
    attr_accessor :sources
    attr_accessor :dependencies
  end
end
