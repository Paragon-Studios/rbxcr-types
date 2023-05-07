require "./api.d"
require "./generation/generators/enum_generator"
require "./generation/generators/class_generator"
require "./timer"
require "crest"
require "file_utils"

SECURITY_LEVELS = ["None", "PluginSecurity"]
BASE_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/"
API_DUMP_URL = BASE_URL + "Mini-API-Dump.json"
REFLECTION_METADATA_URL = BASE_URL + "ReflectionMetadata.xml"
TAB = "\t- "

private def check_status(res : Crest::Response) : Exception?
  raise "#{TAB}Request response non-200 status" unless res.status_code == 200
end

private def task_finished(timer : Timer)
  puts "#{TAB}Done! Took #{timer.get_elapsed}ms"
end

relative_out_dir = File.join File.dirname(__FILE__), "..", "out"
out_dir = File.expand_path relative_out_dir
FileUtils.mkdir_p out_dir
total_timer = Timer.new

# Deserialize API reference dump
puts "Fetching data..."
api_dump_timer = Timer.new
puts "#{TAB}Requesting API dump JSON..."

dump_res = Crest.get API_DUMP_URL
api = API::Dump.from_json dump_res.body
puts "#{TAB}Done! Took #{api_dump_timer.get_elapsed}ms"
check_status dump_res

# Deserialize reflection metadata
relection_timer = Timer.new
puts "#{TAB}Requesting reflection metadata..."

relection_res = Crest.get REFLECTION_METADATA_URL
task_finished relection_timer
check_status relection_res

reflection_metadata = ReflectionMetadata.new relection_res.body

# Enum generation
enum_gen_timer = Timer.new
puts "Generating enums..."

enums_file = File.join out_dir, "generated", "Enums.d.cr"
enum_gen = EnumGenerator.new enums_file, reflection_metadata
enum_gen.generate api.enums

task_finished enum_gen_timer

# Class generation
class_gen_timer = Timer.new
puts "Generating classes..."

defined_class_names = Set(String).new
class_files = [] of String
SECURITY_LEVELS.size.times do |i|
  classes_file = File.join out_dir, "generated", "#{SECURITY_LEVELS[i]}.d.cr"
  class_files << classes_file

  ClassGenerator.new(
    classes_file,
    reflection_metadata,
    defined_class_names,
    SECURITY_LEVELS[i],
    SECURITY_LEVELS[i - 1]
  ).generate api.classes
end

task_finished class_gen_timer

# Test compile generated files
compile_timer = Timer.new
puts "Compiling generated files..."
raise "#{TAB}Failed to compile generated Enums." unless system "crystal run #{enums_file}" # returns true if successful
class_files.each do |file|
  raise "#{TAB}Failed to compile generated classes." unless system "crystal run #{file}"
end
task_finished compile_timer
