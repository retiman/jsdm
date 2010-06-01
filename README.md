Description
===========

JSDM is a JavaScript dependency management library written in Ruby - that is
all.  It does not do anything special; in fact, it could be used to manage
dependencies for any language as you can change what JSDM considers a
comment or a require statement.  JSDM will also...

* Perform topological sort to report circular dependencies to you.
* Allow you to have globs in your require statements.
* Allow you to specify load paths.

Installation
============
To install from source:

    rake clobber
    rake package
    gem install pkg/jsdm-*.gem

To install from rubygems.org:

    gem install jsdm

Usage
=====
In your Javascript files, put #require directives in comments at the top of
your file (note that they must be the non-whitespace characters in your file
for JSDM to process them correctly):

    // #require jquery.js
    // #require MyLibrary1.js
    // #require MyLibrary2.js
    // #require other/*.js
    // #require thing/**/*.js

Next you will need to tell JSDM which directories contain your Javascript
files (this is your load path).

    jsdm = JSDM.new :load_path => %w(path_1 path_2 path_3)

Here is an example for using JSDM to concatenate all your sources into one
big JavaScript file:

    require 'jsdm'

    jsdm = JSDM.new :load_path => %w(path_1 path_2 path_3 path_4)
    File.open('result.js', 'w') do |out|
      jsdm.sources.each do |f|
        out.puts "// Filename: #{f}"
        out.puts File.read(f)
      end
    end

Here is an example that finds all the dependencies for file foo.js so it
can generate the script tags for that file:

    require 'jsdm'

    Dir.chdir '/path/to/local/js/files' do
      jsdm = JSDM.new :load_path => '.'
      jsdm.dependencies_for('foo.js').each do |f|
        puts "<script src='/path/to/server/js/files/#{f}' />"
      end
    end

License
=======
The following is retained from BorderStylo's licensing terms:

JSDM version 0.2.20 and above is licensed under the MIT license.

No license is granted for versions previous to 0.2.20.
