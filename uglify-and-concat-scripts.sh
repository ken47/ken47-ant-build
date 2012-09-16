#!/usr/bin/env ruby

# authored by Ken Hahn
# Sept 16, 2012
# kenhahn85@gmail.com

javascript_base = ARGV[0] # equivalent of ${dir.js}
concatted_filename = ARGV[1] 
ordered_script_list = ARGV[2]
puts "ORDERED SCRIPT LIST:"
puts ordered_script_list
ordered_script_list = ordered_script_list.split("\n")

# r.js will take care of these files
# modernizr is a special case
black_list = [
  'app.js','app_view.js','app_config.js','app_controller.js','app_services.js','router.js','layout_controller.js',
  'modernizr-2.5.3.min.js','text.js'
]

puts "*********************"
puts "\nRequireJS INTELLIGENT CONCATENATION"
puts "*********************"
require_output = `r.js -o #{javascript_base}/require.conf`
puts require_output

puts "*********************"
puts "ORDERED SCRIPTS"
puts "*********************"
ordered_script_list.each do |filepath|
  if filepath.split('/').last == 'app.js'
    next
  end 

  black_list.push filepath.split('/').last
  puts "Processing: #{filepath}"
  `uglifyjs -nc #{javascript_base}/../#{filepath} >> #{concatted_filename}`
  # `cat #{javascript_base}/../#{filepath} >> #{concatted_filename}`

end
puts "*********************"
puts "EVERYTHING ELSE"
puts "*********************"
Dir["#{javascript_base}/**/*.js"].each do |filepath|
  if black_list.include? filepath.split('/').last
    next
  end 

  puts "Processing: #{filepath}"
  `uglifyjs -nc #{filepath} >> #{concatted_filename}`
  # `cat #{filepath} >> #{concatted_filename}`
end
