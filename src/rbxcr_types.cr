require "./class/reflection_metadata"
require "./class/timer"
require "./api.d"
require "crest"

SECURITY_LEVELS = ["None", "PluginSecurity"]
BASE_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/"
API_DUMP_URL = BASE_URL + "Mini-API-Dump.json"
REFLECTION_METADATA_URL = BASE_URL + "ReflectionMetadata.xml"
TAB = "\t- "

private def check_status(res : Crest::Response) : Exception | Nil
  raise "#{TAB}API dump response non-200 status" unless res.status_code == 200
end

out_path = File.join File.dirname(__FILE__), "..", "out"
total_timer = Timer.new
puts "Generating..."

api_dump_timer = Timer.new
puts "#{TAB}Requesting API dump JSON..."

dump_res = Crest.get API_DUMP_URL
api = API::Dump.from_json dump_res.body
puts "#{TAB}Done! Took #{api_dump_timer.get_elapsed}ms"
check_status dump_res

relection_timer = Timer.new
puts "#{TAB}Requesting reflection metadata..."
relection_res = Crest.get REFLECTION_METADATA_URL
puts "#{TAB}Done! Took #{relection_timer.get_elapsed}ms"
check_status relection_res

reflection_metadata = ReflectionMetadata.new relection_res.body

