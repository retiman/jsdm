require 'tempfile'

class JSDM
  class Spidermonkey
    def self.check(files, options = {})
      options = {
        :strict  => false,
        :werror  => false,
        :atline  => false,
        :xml     => false,
        :output  => true,
        :heading => "print('Checking $FILE$');"
      }.merge! options
      tmp = Tempfile.new("jsdm")
      options.select { |k, v| v }.
              each   { |k, v| tmp.puts "options('#{k.to_s}');" }
      files.each do |f|
        h = options[:heading].gsub(/\$FILE\$/, f)
        tmp.puts h
        tmp.puts "load('#{f}');"
      end
      tmp.flush
      system "js -f #{tmp.path} #{options[:output] ? '' : '&>/dev/null'}"
    end
  end
end
