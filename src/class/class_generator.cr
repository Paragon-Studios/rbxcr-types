require "../api.d"
require "./constants"

PROP_TYPE_MAP = {} of String => String

def contains_bad_char?(name : String) : Bool
  BAD_NAME_CHARS.each do |bad_char|
    return true if name.includes? bad_char
  end
	false
end

def safe_name?(name : String) : Bool
  return contains_bad_char? name ? "[\"#{name.gsub(/\"/, "\\\"")}\"]" : name
end

def safe_prop_type(value_type : String?)
  return nil if value_type.nil?
  PROP_TYPE_MAP[value_type] || value_type
end

def safe_value_type(value_type : API::ValueType)
  return "Enum::#{value_type.name}" if value_type.category == "Enum"
  if value_type.name[-1] == "?"
    non_optional_type = value_type.name[0..-2]
    mapped_type = VALUE_TYPE_MAP[non_optional_type]
    (mapped_type || non_optional_type) + "?"
  else
    VALUE_TYPE_MAP[value_type.name] || value_type.name
  end
end

def safe_return_type(value_type : String?)
  return nil if value_type.nil?
  mapped_type = RETURN_TYPE_MAP[value_type]
  return mapped_type unless mapped_type.nil?
  value_type
end

def safe_arg_name(name : String?)
  return nil if name.nil?
  ARG_NAME_MAP[name] || name
end

security_override : HashMap(String, HashMap(String, API::MemberBase)) = {
  "StarterGui" => {
    "ShowDevelopmentGui" => "PluginSecurity"
  }
}

def get_security(class_name : String, member : API::MemberBase) : String | HashMap(String, String)
  security = security_override[class_name]&[member.name] || member.security || "None"
  security.is_a?(String) ? { "read" => security, "write" => security } : security
end

