#!/usr/bin/env ruby

# authored by Ken Hahn
# Sept 16, 2012
# kenhahn85@gmail.com
class TemplateConcatenator
  def initialize()
    dir_source = ARGV[0]
    @intermediate_index_file = ARGV[1]
    @subdir_templates = ARGV[2]

    @dir_templates = dir_source + '/' + @subdir_templates
    self.main()
  end

  def main()
    self.concat_templates
  end

  def concat_templates()
    puts "\n\n*********************"
    puts "CONCATTING TEMPLATES WITH INDEX"
    puts "*********************"

    text = File.read(@intermediate_index_file)
    text.insert(text.index('</body>'), '<div id="templates"></div>')

    Dir["#{@dir_templates}/**/*.html"].each do |filepath|
      components = filepath.split('/').pop(2)
      id1 = components[0]
      id2 = components[1].split('.').shift()
      contents = File.read(filepath)
      contents = "<div id='#{id1}-#{id2}-template'>"+contents+"</div>"
      text.insert(text.index('</body>') - 6, contents)
    end

    File.open(@intermediate_index_file, 'w') {|file| file.write text}
  end
end

TemplateConcatenator.new()
