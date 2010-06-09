require 'jsdm/errors'

class JSDM
  # Resolves filenames and globs in a #require statement, relative to a load
  # path.
  class DependencyResolver
    attr_accessor :load_path

    def initialize(load_path)
      self.load_path = load_path
    end

    # Returns a list of actual files that have been resolved.
    #
    # For example, if you do:
    #
    #   // #require foo/*.js, bar/*.js
    #
    # This function will resolve those to actual file names.
    def process(entries)
      entries.map { |entry| process_single entry }.
              flatten
    end

    # Resolve a single entry in a require statement.  For example, if a source
    # file #require's foo.js, this function will resolve foo.js to the proper
    # file in your load_path.  The first directory in your load_path that
    # contains foo.js will win; other files matching foo.js will be discarded.
    #
    # Incidentally, if you ask to resolve *.js, then this resolves to the first
    # directory in your load_path!  Similarly, if you ask to resolve foo/*.js,
    # it resolves to the first non-empty directory foo in your load_path.
    #
    # Be careful about using globs with multiple load paths.
    def process_single(entry)
      resolved = load_path.map { |path| Dir[File.join(path, entry.strip)] }.
                           drop_while { |sources| sources.empty? }.
                           first
      raise FileNotFoundError.new(entry) if resolved.nil? || resolved.empty?
      resolved
    end
  end
end

