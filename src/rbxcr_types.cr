require "./timer"
require "./api.d"
require "crest"

SECURITY_LEVELS = ["None", "PluginSecurity"]
BASE_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/"
API_DUMP_URL = BASE_URL + "Mini-API-Dump.json"
REFLECTION_METADATA_URL = BASE_URL + "ReflectionMetadata.xml"

def check_status(res : Crest::Response) : Exception | Nil
  raise "#{tab}API dump response non-200 status" unless res.status_code == 200
end

module TypeGenerator
  out_path = File.join File.dirname(__FILE__), "..", "out"
  total_timer = Timer.new
  puts "Generating..."
  tab = "\t- "

  api_dump_timer = Timer.new
  puts "#{tab}Requesting API dump JSON..."

  dump_res = Crest.get API_DUMP_URL
  api = API::Dump.from_json dump_res.body
  puts "#{tab}Done! Took #{api_dump_timer.get_elapsed}ms"
  check_status dump_res

  relection_timer = Timer.new
  puts "#{tab}Requesting reflection metadata..."
  relection_res = Crest.get REFLECTION_METADATA_URL
  puts "#{tab}Done! Took #{relection_timer.get_elapsed}ms"
  check_status relection_res

  reflection_metadata = ReflectionMetadata.new relection_res.body
end
