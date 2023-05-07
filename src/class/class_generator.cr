require "../api.d"
require "./constants"
require "./generator"
require "./reflection_metadata"

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

def multifilter(list : Array(T), result_arr_amount : Int64, &condition : T -> Float64) forall T
  results = [] of Array(T)
  result_arr_amount.times { |i| results[i] = [] of T }
  list.each { |element| results[condition element] << element }
  results
end

class ClassGenerator < Generator
  @class_refs = {} of String => API::Class

  def initialize(
    file_path : String,
    @metadata : ReflectionMetadata,
    @defined_class_names : Set(String),
    @security : String,
    @lower_security : String?
  )
    super file_path, @metadata
  end

  private def can_read?(class_name : String, member : API::MemberBase) : Bool
    read_security = get_security(class_name, member)["read"]
    read_security == @security ||
      (PLUGIN_ONLY_CLASSES.includes?(class_name) && read_security == @lower_security)
  end

  private def can_write?(class_name : String, member : API::MemberBase) : Bool
    write_security = get_security(class_name, member)["write"]
    write_security == @security ||
      (PLUGIN_ONLY_CLASSES.includes?(class_name) && write_security == @lower_security)
  end

  private def is_plugin_only_class?(rbx_class : API::Class) : Bool
    if PLUGIN_ONLY_CLASSES.has_key?(rbx_class.name)
      true
    else
      superclass = @class_refs[rbx_class.superclass]
      superclass ? is_plugin_only_class?(superclass) : false
    end
  end

  private def should_generate_class?(rbx_class : API::Class) : Bool
    superclass = @class_refs[rbx_class.superclass]
    return false if !superclass.nil? && !should_generate_class?(superclass)
    return false if CLASS_BLACKLIST.has_key?(rbx_class.name)
    return false if @security != "PluginSecurity" && PLUGIN_ONLY_CLASSES.has_key?(rbx_class.name)
    true
  end

  private def should_generate_member?(rbx_class : API::Class, member : API::MemberBase) : Bool
    return false if MEMBER_BLACKLIST[rbx_class.name] && MEMBER_BLACKLIST[rbx_class.name].as(Hash(String, String)).has_key?(member.name)
    return false unless can_read?(rbx_class.name, member)
    if has_tag?(member, "Deprecated")
      first_char = member.name[0]
      if first_char == first_char.downcase
        pascal_case_name = first_char.upcase + member.name[1..-1]
        pascal_case_member = rbx_class.members.find { |v| v.name == pascal_case_name }
        return false unless pascal_case_member.nil?
      end
    end
    return false if has_tag?(member, "NotScriptable")
    true
  end

  # for writing documentation
  private def write_description(member : API::MemberBase, description : String?) : Nil

  end

  private def generate_class_name(class_name : String)
    return class_name if @class_refs[class_name]
    raise "Undefined class name: #{class_name}"
  end

  private def generate_instance_class(
		table_name : String,
		rbx_classes : Array(API::Class),
		extended : String?,
		&callback : (API::Class -> Nil)?
	)
		write "class #{table_name} #{rbx_classes.empty? ? "; end" : ""}"
		unless rbx_classes.empty?
      write "include #{extended}"
      push_indent

			if callback.nil?
        callback = proc do |api_class|
          write "#{api_class.name} : #{api_class.name}"
        end
			end

			rbx_classes.each(callback);
			pop_indent
			write "end"
		end
		write ""
	end

  private def by_name(a : API::Class, b : API::Class) : Int32
    a.name.downcase < b.name.downcase ? -1 : 1
  end

  private def generate_instances_tables(rbx_classes : Array(API::Class))
    services, creatable_instances, abstract_instances, instances = multifilter(rbx_classes, 4) do |rbx_class|
      ((has_tag?(rbx_class, "Service") ? 0 : is_creatable?(rbx_class)) ?
        1 : ABSTRACT_CLASSES.has_key?(rbx_class.name)) ? 2 : 3
    end

    generate_instance_class("Services", services.sort by_name) unless services.empty?
    generate_instance_class("CreatableInstances", creatable_instances.sort by_name) unless creatable_instances.empty?
    generate_instance_class("AbstractInstances", abstract_instances.sort by_name) unless creatable_instances.empty?
    generate_instance_class("Instances", instances.sort by_name, "Services, CreatableInstances, AbstractInstances") unless instances.empty?
  end

  private def generate_header
    write "# THIS FILE IS AUTOMATICALLY GENERATED AND SHOULD NOT BE EDITED MANUALLY!"
    write ""

    write "require \"./#{@lower_security}.d\"" unless @lower_security.nil?
    write "require \"../roblox.d\""
    write "require \"./enums.d\""
    write ""
  end

  def generate(rbx_classes : Array(API::Class))
    rbx_classes.each do |rbx_class|
      class_name = rbx_class.name
      rbx_class.subclasses = [] of String

      @class_refs[class_name] = rbx_class
      superclass = @class_refs[rbx_class.superclass]
      superclass.subclasses << class_name
    end

    classes_to_generate = rbx_classes.select { |rbx_class| should_generate_class?(rbx_class) }
    generate_header
    generate_instances_tables(classes_to_generate.select { |rbx_class| @defined_class_names.includes?(rbx_class.name) })
  end
end
