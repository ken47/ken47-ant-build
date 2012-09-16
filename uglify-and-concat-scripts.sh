#!/usr/bin/env ruby

# authored by Ken Hahn
# Sept 16, 2012
# kenhahn85@gmail.com
class UglifyHelper
  @@tmp = 'build/tmp.txt'

  def initialize()
    # r.js will take care of these files
    # modernizr is a special case
    @black_list = [
      'app.js','app_view.js','app_config.js','app_controller.js','app_services.js','router.js','layout_controller.js',
      'modernizr-2.5.3.min.js','text.js'

    ]
    @javascript_base = ARGV[0] # equivalent of ${dir.js}
    @concatted_filename = ARGV[1] 
    @ordered_script_list = ARGV[2].split("\n")
    self.main()
  end

=begin
  def comment_out_log_statements(filepath)
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
    filepath = @javascript_base + joint + filepath
    text = File.read(filepath)
    if text.include? "console.log"
      puts '########'
      puts "console.log statements detected in " + filepath.split('/').last
      puts '########'
      next_console_log = 0
      while true do
        next_console_log = text.index('console.log', next_console_log)

        if next_console_log.nil?
          break
        end

        next_opening_paren = text.index('(',next_console_log) 
        next_closing_paren = text.index(')',next_console_log) 
        
        # once this loop is broken, next_closing_paren should contain the position of the closing paren for console.log
        while true do
          next_opening_paren = text.index('(',next_opening_paren+1)

          if next_opening_paren.nil?
            break
          end

          if next_opening_paren > next_closing_paren
            break
          else
            next_closing_paren = text.index(')',next_closing_paren+1)   
          end
        end

        text.insert (next_closing_paren +1 ), "*/"
        text.insert (next_console_log), "/*"
        next_console_log += 3 
        puts text[(next_console_log-3)..(next_closing_paren+4)]
      end
    end
    File.open(@@tmp, 'w') {|file| file.write text}
  end
=end

  def get_filepath(filepath)
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
    return @javascript_base + joint + filepath
  end

  def cleanup()
    puts "\n\n*********************"
    puts "DELETING STALE R.JS CONCATTED FILES"
    puts "*********************"
    Dir["#{@javascript_base}/**/*.js"].each do |filepath|
      if File.basename(filepath) =~ /^app-built/ 
        puts 'Deleting ' + filepath
        File.delete(filepath)
      end
    end
  end

  def main()
    self.cleanup

    puts "\n\n*********************"
    puts "RequireJS INTELLIGENT CONCATENATION"
    puts "*********************"
    require_output = `r.js -o #{@javascript_base}/require.conf`
    puts require_output

    # set env to production

    trigger = false
    puts "\n\n*********************"
    puts "ORDERED SCRIPTS"
    puts "*********************"
    @ordered_script_list.each do |filepath|
      filepath = self.get_filepath(filepath)
      # we will be using app-built-xyz.js from r.js above
      if File.basename(filepath) == 'app.js'
        next
      end 

      unless trigger
        trigger = true
        # can inject this into any file before app-built-xyz.js is loaded
        File.open(filepath, 'a') do |file|
          puts "file opened"
          file.write "window.Project = { env: 'production' };"
        end
      end

      @black_list.push filepath.split('/').last

      puts "Processing: #{filepath}"
      # self.comment_out_log_statements filepath
      # `uglifyjs -nc #{filepath} >> #{@concatted_filename}`
      `cat #{filepath} >> #{@concatted_filename}`
      # `cat #{@javascript_base}/../#{@@tmp} >> #{@concatted_filename}`
    end

    puts "\n\n*********************"
    puts "EVERYTHING ELSE"
    puts "*********************"
    Dir["#{@javascript_base}/**/*.js"].each do |filepath|
      filepath = self.get_filepath(filepath)
      if @black_list.include? File.basename(filepath)
        next
      end 

      puts "Processing: #{filepath}"
      # self.comment_out_log_statements filepath
      # `uglifyjs -nc #{filepath} >> #{@concatted_filename}`
      `cat #{filepath} >> #{@concatted_filename}`
    end
  end
end

UglifyHelper.new()
