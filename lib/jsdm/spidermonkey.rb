require 'tempfile'

class JSDM
  class Spidermonkey
    def self.check(files, options = {})
      options = {
        :strict  => false,
        :werror  => false,
        :atline  => false,
        :xml     => false,
        :output  => true
      }.merge! options
      tmp = Tempfile.new("jsdm")
      options.select { |k, v| v }.
              each   { |k, v| tmp.puts "options('#{k.to_s}');" }
      files.each do |file|
        tmp.puts "print('Running #{file}');"
        tmp.puts "load('#{file}');"
      end
      tmp.flush
      system "js -f #{tmp.path} #{options[:output] ? '' : '&>/dev/null'}"
    end
  end
end
