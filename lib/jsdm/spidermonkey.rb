require 'tempfile'

class JSDM
  class Spidermonkey
    def initialize(sources, options = {})
      defaults = {
        :strict  => false,
        :werror  => false,
        :atline  => false,
        :xml     => false,
        :verbose => false,
        :output  => true
      }
      self.options = defaults.merge! options
      self.sources = sources
    end

    def check
      puts "Checking Javascript with Spidermonkey" if options[:verbose]
      tmp = Tempfile.new("jsdm")
      options.select { |k, v| v }.
              each   { |k, v| tmp.puts "options('#{k.to_s}');" }
      sources.each do |source|
        tmp.puts "print('Processing #{source}...');"
        tmp.puts "load('#{source}');"
      end
      tmp.flush
      system "js -f #{tmp.path} #{options[:output] ? '' : '&>/dev/null'}"
    end

    attr_accessor :options, :sources
  end
end
