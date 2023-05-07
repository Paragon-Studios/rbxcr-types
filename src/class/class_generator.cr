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

def safe_prop_type(value_type : String?) : String?
  return nil if value_type.nil?
  PROP_TYPE_MAP[value_type] || value_type
end

def safe_value_type(value_type : API::ValueType) : String
  return "Enum::#{value_type.name}" if value_type.category == "Enum"
  if value_type.name[-1] == "?"
    non_optional_type = value_type.name[0..-2]
    mapped_type = VALUE_TYPE_MAP[non_optional_type]
    (mapped_type || non_optional_type) + "?"
  else
    VALUE_TYPE_MAP[value_type.name] || value_type.name
  end
end

def safe_return_type(value_type : String?) : String?
  return nil if value_type.nil?
  mapped_type = RETURN_TYPE_MAP[value_type]
  return mapped_type unless mapped_type.nil?
  value_type
end

def safe_arg_name(name : String?) : String?
  return nil if name.nil?
  ARG_NAME_MAP[name] || name
end

security_override = {
  "StarterGui" => {
    "ShowDevelopmentGui" => "PluginSecurity"
  }
} of String => Hash(String, String)

def get_security(class_name : String, member : API::MemberBase) : String | Hash(String, String)
  security = security_override[class_name]&[member.name] || member.security || "None"
  security.is_a?(String) ? { "read" => security, "write" => security } : security
end

def has_tag?(container : API::MemberBase | API::Class, tag : String) : Bool
  return container.tags.includes?(tag) unless container.tags.nil?
  false
end

def is_creatable?(rbx_class : API::Class) : Bool
  !CREATABLE_BLACKLIST.has_key?(rbx_class.name) && !has_tag?(rbx_class, "NotCreatable") && !has_tag?(rbx_class, "Service")
end

def multifilter(list : Array(T), result_arr_amount : Int64, condition : T -> Float64) forall T
  results = [] of Array(T)
  result_arr_amount.times { |i| results[i] = [] of T }
  list.each { |element| results[condition element] << element }
  results
end
