#!/usr/bin/env ruby

# authored by Ken Hahn
# Sept 16, 2012
# kenhahn85@gmail.com
require 'fileutils'

source_dir = ARGV[0]
publish_dir = ARGV[1]
intermediate_dir = ARGV[2]

# assumes that the source dir is only one tier beneath app_directory
# e.g. [project name]/[source dir]
# may have to alter if nested more than one tier deep
source_dir_components = source_dir.split('/')
while true do
  app_dir = source_dir_components.shift()
  if app_dir != '.'
    break 
  end
end

if File.exists?(app_dir + '-backup')
  FileUtils.rm_rf app_dir + '-backup' 
end

FileUtils.cp_r app_dir, app_dir + '-backup'
FileUtils.rm_rf source_dir 
FileUtils.mv publish_dir, source_dir
FileUtils.rm_rf intermediate_dir

Dir.chdir(source_dir + '/..')
puts `git add --all`
# puts `git status --porcelain | awk '/^.D .*$/ {print $2}' | xargs git rm`
puts `git rm -r public/templates`
puts `git add .`
time = Time.new
current_time = time.inspect
puts `git commit -m 'ant build for master (production) branch @#{current_time}'`
puts `INSTALLING ANY NEW NODE DEPS`
puts `npm install`
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
puts 'you are now on the production branch'
puts 'scroll up to the -mkdirs section of the script and ensure that there are no conflicts'
puts 'if there are conflicts, you can go to the [project name]-backup dir, fix, and retry'
puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
