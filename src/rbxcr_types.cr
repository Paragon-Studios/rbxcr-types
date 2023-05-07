require "./class/enum_generator"
require "./class/timer"
require "./api.d"
require "crest"

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

enums_file = File.join(out_dir, "generated", "enums.cr")
enum_gen = EnumGenerator.new enums_file, reflection_metadata
enum_gen.generate api.enums

task_finished enum_gen_timer

# Test compile generated enums
raise "#{TAB}Failed to compile generated Enums." unless system "crystal run #{enums_file}"
