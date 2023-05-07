require "xml"

class ReflectionMetadata
  getter metadata : XML::Node

  def initialize(raw_xml : String)
    @metadata = XML.parse raw_xml
  end

  def get_class_desc(name : String) : String?
    get(class_prefix(name) + "Properties/string[@name='summary']")
  end

  def get_member_desc(class_name : String, name : String, specifier : Array(String)) : String?
    specifier_string = specifier.map { |v| "@class='#{v}'" }.join " or "
    get(
      class_prefix(class_name) +
      "Item[#{specifier_string}]/"\
      "Item[@class='ReflectionMetadataMember']/"\
      "Properties/"\
      "string[@name='Name'][text()='#{name}']"\
      "/../string[@name='summary']"
    )
  end

  def get_prop_desc(class_name : String, name : String) : String?
    get_member_desc class_name, name, ["ReflectionMetadataProperties"]
  end

  def get_method_desc(class_name : String, name : String) : String?
    get_member_desc(
      class_name,
      name,
      ["ReflectionMetadataFunctions", "ReflectionMetadataYieldFunctions"]
    )
  end

  def get_callback_desc(class_name : String, name : String) : String?
    get_member_desc class_name, name, ["ReflectionMetadataCallbacks"]
  end

  def get_event_desc(class_name : String, name : String) : String?
    get_member_desc class_name, name, ["ReflectionMetadataEvents"]
  end

  private def class_prefix(name : String) : String?
    "//Item[@class='ReflectionMetadataClass']/Properties/string[@name='Name'][text()='#{name}']/../../"
  end

  private def get(query : String) : String?
    set = @metadata.xpath query
    result : String? = set.to_s unless set.nil?
    filter result unless result.nil?
  end

  private def filter(s : String) : String?
    s.gsub(/<a href="([^"]+)"[^>]+>([^<]+)<\/a>/) do |_, *args|
      link = args[-1]
      text = args[0]
      "[#{text}](#{link})"
    end
  end
end
