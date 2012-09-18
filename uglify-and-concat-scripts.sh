#!/usr/bin/env ruby

# authored by Ken Hahn
# Sept 16, 2012
# kenhahn85@gmail.com
class UglifyHelper
  def initialize()
    # r.js will take care of these files
    # modernizr is a special case
    @black_list = [
      'app.js','app_view.js','app_config.js','app_controller.js','app_services.js','router.js','layout_controller.js',
      'modernizr-2.5.3.min.js','text.js'
    ]
    dir_source = ARGV[0]
    dest_script_name = ARGV[1]
    file_root_page = ARGV[2]
    dir_publish = ARGV[3]
    @subdir_js = ARGV[4]
    @ordered_script_list = ARGV[5].split("\n")

    @dir_js = dir_source + '/' + @subdir_js
    @concatted_js = dir_publish + '/' + @subdir_js + '/' + dest_script_name
    @concatted_html = dir_publish + '/' + file_root_page
    self.main()
  end

  def main()
    self.cleanup
    self.process_requirejs
    self.process_ordered_scripts
    self.process_everything_else
  end

  def get_js_filepath(filepath)
    joint = '/'
    filepath.split('/').to_enum.with_index(0) do |component, index|
      if component == '.'
        next
      else 
        joint += '../'
        if component != 'js'
          next 
        else
          break
        end
      end
    end
    return @dir_js + joint + filepath
  end

  def cleanup()
    puts "\n\n*********************"
    puts "DELETING STALE R.JS CONCATTED FILES"
    puts "*********************"
    Dir["#{@dir_js}/**/*.js"].each do |filepath|
      if File.basename(filepath) =~ /^app-built/ 
        puts 'Deleting ' + filepath
        File.delete(filepath)
      end
    end
  end

  def process_ordered_scripts()
    puts "\n\n*********************"
    puts "ORDERED SCRIPTS"
    puts "*********************"
    @ordered_script_list.each do |filepath|
      filepath = self.get_js_filepath(filepath)
      # we will be using app-built-xyz.js from r.js above
      if File.basename(filepath) == 'app.js'
        next
      end 

      @black_list.push filepath.split('/').last

      puts "Processing: #{filepath}"
      `uglifyjs -nc #{filepath} >> #{@concatted_js}`
      # `cat #{filepath} >> #{@concatted_js}`
    end
  end

  def process_requirejs()
    puts "\n\n*********************"
    puts "RequireJS INTELLIGENT CONCATENATION"
    puts "*********************"
    require_output = `r.js -o #{@dir_js}/require.conf`
    puts require_output

    # set env to production
    File.open(@concatted_js, 'a') do |file|
      file.write "window.Project={env:'production'};"
    end
  end

  def process_everything_else()
    puts "\n\n*********************"
    puts "EVERYTHING ELSE"
    puts "*********************"
    Dir["#{@dir_js}/**/*.js"].each do |filepath|
      filepath = self.get_js_filepath(filepath)
      if @black_list.include? File.basename(filepath)
        next
      end 

      puts "Processing: #{filepath}"
      `uglifyjs -nc #{filepath} >> #{@concatted_js}`
      # `cat #{filepath} >> #{@concatted_js}`
    end
  end
end

UglifyHelper.new()
