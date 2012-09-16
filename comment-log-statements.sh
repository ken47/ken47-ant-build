#!/usr/bin/env ruby

# authored by Ken Hahn
# Sept 16, 2012
# kenhahn85@gmail.com

javascript_base = ARGV[0] # equivalent of ${dir.js}
concatted_filename = ARGV[1] 
ordered_script_list = ARGV[2]
ordered_script_list = ordered_script_list.split("\n")

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
