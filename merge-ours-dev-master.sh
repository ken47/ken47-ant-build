#!/usr/bin/env ruby

# authored by Ken Hahn
# Sept 16, 2012
# kenhahn85@gmail.com
source_dir = ARGV[0]
Dir.chdir source_dir + '/..'
puts `git checkout dev`
puts `git merge -s ours master`
puts `git add --all`
time = Time.new
current_time = time.inspect
puts `git commit -m 'ant build for dev branch @#{current_time}'`
puts `git checkout master`
puts `git merge dev`
