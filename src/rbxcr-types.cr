require "./timer"

const SECURITY_LEVELS = ["None", "PluginSecurity"]
const BASE_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/"
const API_DUMP_URL = BASE_URL + "Mini-API-Dump.json"
const REFLECTION_METADATA_URL = BASE_URL + "ReflectionMetadata.xml"

module TypeGenerator
  out_path = File.join File.dirname(__FILE__), "..", "out"
  total_timer = Timer.new
  puts "Generating..."

  api_dump_timer = Timer.new
  puts "\t- Requesting API Dump JSON.."


end
