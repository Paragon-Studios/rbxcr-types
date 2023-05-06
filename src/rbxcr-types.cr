require "./timer"
require "crest"

SECURITY_LEVELS = ["None", "PluginSecurity"]
BASE_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/"
API_DUMP_URL = BASE_URL + "Mini-API-Dump.json"
REFLECTION_METADATA_URL = BASE_URL + "ReflectionMetadata.xml"

module TypeGenerator
  out_path = File.join File.dirname(__FILE__), "..", "out"
  total_timer = Timer.new
  puts "Generating..."

  api_dump_timer = Timer.new
  puts "\t- Requesting API Dump JSON..."

  api_dump_res = JSON.parse(Crest.get API_DUMP_URL)
  puts "\t- Done! Took #{api_dump_timer.get_elapsed}ms"
  raise "API dump response non-200 status" if api_dump_res.status


end
