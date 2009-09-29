require 'jsdm/circular_dependency_error'
require 'jsdm/depth_first_search'
require 'jsdm/file_not_found_error'
require 'jsdm/natural_loops'
require 'jsdm/unsatisfiable_dependency_error'

module JSDM
  class DependencyManager
    def initialize(load_path, options = {})
      defaults = {
        :verbose   => false,
        :extension => "js"
      }
      self.load_path = load_path
      self.options = defaults.merge! options
      self.sources = get_all_sources
      self.dependencies = []
      self.graph = nil
    end

    def add_dependencies(source, includes)
      begin
        puts "Dependencies for #{source}:" if options[:verbose]
        resolved = resolve_entries(includes)
        resolved.each do |dep|
          # make an arc from dep to source
          # in a dfs, dep will be visited before source
          # files implicitly depend on themselves; this is not an error
          puts "  #{dep}" if options[:verbose]
          dependencies << [dep, source] unless same_file?(dep, source)
        end
        puts "  (None)" if options[:verbose] && resolved.empty?
      rescue FileNotFoundError => e
        raise UnsatisfiableDependencyError.new(source, e.file)
      end
    end

    def resolve_entries(entries)
      entries.map { |entry| resolve_entry(entry) }.flatten
    end
    
    def resolve_entry(entry)
      resolved = load_path.map { |path| Dir["#{path}/#{entry.strip}"] }.
                           drop_while { |sources| sources.empty? }.
                           first
      raise FileNotFoundError.new(entry) if resolved.nil? || resolved.empty?
      resolved
    end    

    def process
      # todo: warn about listing the same dependency twice
      # todo: warn about including the same source twice
      self.sources = sources.uniq.select { |s| !s.empty? }
      self.dependencies = dependencies.uniq.select { |s| !s.empty? }
      self.graph = DirectedGraph.new(sources, dependencies)
      result = dfs(graph)
      loops = loops(graph, result[:back_edges])
      raise CircularDependencyError.new(loops) unless loops.empty?
      result[:sorted] 
    end

    # todo: refactor out of class
    def get_all_sources
      ext = options[:extension]
      load_path.map { |path| Dir["#{path}/**/*.#{ext}"] }.flatten
    end    

    # todo: refactor out of class
    def same_file?(a, b)
      File.expand_path(a) == File.expand_path(b)
    end

    attr_accessor :load_path, :sources, :dependencies, :graph, :options
    private :load_path=, :sources=, :dependencies=, :graph=, :options=
  end
end
