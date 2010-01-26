JSDM
====

JSDM is a javascript dependency management library written in Ruby.  Unlike other dependency management libraries, JSDM will perform a topological sort to determine any circular dependencies for you.  It also lets you specify dependencies as globs (eg #require lib/*.js).

Building
--------
You will want the latest tag instead of what is in master (which could be unstable).

Just checkout the latest tag and run rake install.

    git fetch --tags
    git tag -l
    git checkout <tagname>
    rake install

This will install JSDM as a gem.

Usage
-----
In your Javascript files, put #require directives in comments at the top of your file (note that they must be the non-whitespace characters in your file for JSDM to process them correctly):

    // #require jquery.js
    // #require MyLibrary1.js
    // #require MyLibrary2.js
    // #require other/*.js

Next you will need to tell JSDM which directories contain your Javascript files (this is your load path).

Here is an example of using JSDM with Rake.  This will get you all the dependencies of foo.js and concatenate them into one big Javascript file.

    require 'jsdm'

    task :concat
      load_path = %w(path_1 path_2 path_3 path_4)
      jsdm = JSDM.new load_path
      File.open('result.js', 'w') do |out|
        jsdm.sources_for('foo.js').each do |source|
          out.puts "// Filename: #{File.expand_path source}"
          out.puts File.read(source)
        end
      end
    end

Here is an example that runs all the Javascript sources through Spidermonkey to check for errors.

    require 'jsdm'
    require 'tempfile'

    task :concat
      load_path = %w(path_1 path_2 path_3 path_4)
      jsdm = JSDM.new load_path
      tmp = Tempfile.new('jsdm')
      jsdm.sources.each do |source|
        tmp.puts "print('Checking #{source}\n');"
        tmp.puts "load('#{source}')"
      end
      tmp.flush
      system "js -f #{tmp.path}"
    end

License
-------
JSDM version 0.2.20 and above is licensed under the MIT license.

No license is granted for versions previous to 0.2.20.
