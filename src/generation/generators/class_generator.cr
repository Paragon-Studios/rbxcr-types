require "../constants"
require "../reflection_metadata"
require "./generator"

PROP_TYPE_MAP = {} of String => String

class String
  def trim
    gsub(/\A\s+|\s+\z/, "")
  end
  def format_comment
    trim.split('\n').map { |d| "# #{d}" }.join("\n")
  end
end

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

def safe_renamed_instance(name : String?) : String?
  return nil if name.nil?
  RENAMEABLE_AUTO_TYPES.has_key?(name) ? RENAMEABLE_AUTO_TYPES[name] : name
end

def safe_value_type(value_type : API::ValueType) : String
  return "Enum::#{value_type.name}" if value_type.category == "Enum"
  if value_type.name[-1] == "?"
    non_optional_type = value_type.name[0..-2]
    mapped_type = VALUE_TYPE_MAP[non_optional_type]
    (mapped_type || non_optional_type) + '?'
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

def get_security(class_name : String, member : API::MemberBase) : Hash(String, String)
  security_override = {
    "StarterGui" => {
      "ShowDevelopmentGui" => "PluginSecurity"
    }
  } of String => Hash(String, String)
  security = security_override[class_name][member.name] || member.security || "None"
  security.is_a?(String) ? { "read" => security, "write" => security } : security.as_hash
end

def has_tag?(container : API::MemberBase | API::Class, tag : String) : Bool
  return container.tags.not_nil!.includes?(tag) unless container.tags.nil?
  false
end

def is_creatable?(rbx_class : API::Class) : Bool
  !CREATABLE_BLACKLIST.includes?(rbx_class.name) && !has_tag?(rbx_class, "NotCreatable") && !has_tag?(rbx_class, "Service")
end

def multifilter(list : Array(T), result_arr_amount : Int32, &condition : T -> Int32) : Array(Array(T)) forall T
  results = Array(Array(T)).new
  result_arr_amount.times do |i|
    results << [] of T
  end
  list.each do |element|
    results[condition.call element] << element
  end
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
    if PLUGIN_ONLY_CLASSES.includes?(rbx_class.name)
      true
    else
      superclass = @class_refs[rbx_class.superclass]
      superclass ? is_plugin_only_class?(superclass) : false
    end
  end

  private def should_generate_class?(rbx_class : API::Class) : Bool
    superclass = rbx_class.superclass != ROOT_CLASS_NAME ? @class_refs[rbx_class.superclass] : nil
    return false if !superclass.nil? && !should_generate_class?(superclass)
    return false if CLASS_BLACKLIST.includes?(rbx_class.name)
    return false if @security != "PluginSecurity" && PLUGIN_ONLY_CLASSES.includes?(rbx_class.name)
    true
  end

  private def should_generate_member?(rbx_class : API::Class, member : API::MemberBase) : Bool
    return false if !MEMBER_BLACKLIST[rbx_class.name].nil? && MEMBER_BLACKLIST[rbx_class.name].includes?(member.name)
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

  private def generate_instance_class(
		table_name : String,
		rbx_classes : Array(API::Class),
		extended : String?,
		&callback : API::Class -> Nil
	)
		write "module #{table_name} #{rbx_classes.empty? ? "; end" : ""}"
		unless rbx_classes.empty?
      push_indent
      extended.split(", ").each do |extension|
        write "include #{extension}"
        write ""
      end unless extended.nil?

			if callback.nil?
        callback = ->(api_class : API::Class) { write "#{api_class.name} : #{api_class.name}" }
			end

			rbx_classes.each do |rbx_class|
        callback.call rbx_class
      end
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
        1 : ABSTRACT_CLASSES.includes?(rbx_class.name)) ? 2 : 3
    end
    (generate_instance_class("Services", services.sort { |a, b| by_name a, b }, nil) { |rbx_class| rbx_class }) unless services.empty?
    (generate_instance_class("CreatableInstances", creatable_instances.sort { |a, b| by_name a, b }, nil) { |rbx_class| rbx_class }) unless creatable_instances.empty?
    (generate_instance_class("AbstractInstances", abstract_instances.sort { |a, b| by_name a, b }, nil) { |rbx_class| rbx_class }) unless creatable_instances.empty?
    (generate_instance_class("Instances", instances.sort { |a, b| by_name a, b }, "Services, CreatableInstances, AbstractInstances") { |rbx_class| rbx_class }) unless instances.empty?
  end

  # Returns the given `class_name` if it's in `@class_refs`
  # Throws if not
  private def assert_class_name(class_name : String)
    return class_name if @class_refs.has_key?(class_name)
    raise "Undefined class name: #{class_name}"
  end

  # something
  private def generate_class(rbx_class : API::Class)
    @defined_class_names << rbx_class.name
    class_name = assert_class_name rbx_class.name

    members = rbx_class.members.select { |member| should_generate_member?(rbx_class, member) }
    no_security = @security == "None" || is_plugin_only_class?(rbx_class)
    if no_security
      desc = rbx_class.description
      write desc.format_comment unless desc.nil?
    end

    return unless no_security || !members.empty?
    write "module #{class_name}"
    push_indent

    members.each do |member|
      case member.member_type
      when "Callback"
        generate_callback member.as API::Callback, class_name
      when "Event"
        generate_event member.as API::Event, class_name
      when "Function"
        generate_function member.as API::Function, class_name
      when "Property"
        generate_property member.as API::Property, class_name
      end
    end

    pop_indent
    write "end"
  end

  private def get_param_names(params : Array(API::Parameter)) : Array(String)
    param_names = params.map { |param| param.name }
    param_names.each_with_index do |name, i|
      if param_names.index(name) == i + 1
        n = 0
        i.upto(params.size - 1) do |j|
          param_names[j] = "#{name}#{n}"
          n += 1
        end
      end
    end
    param_names
  end

  private def generate_args(params : Array(API::Parameter), args : Array(String) = [] of String) : String
    param_names = get_param_names
    optional = false

    params.each_with_index do |param, i|
      param_type = safe_value_type param.type
      arg_name = safe_arg_name param_names[i]
      optional ||= !param.default.nil? || param_type == "any"
      if !arg_name.nil? && param_type == "Instance"
        findings = [*@class_refs.keys, "Character", "Input"].select do |k|
          k != "Instance" && arg_name.downcase.includes?(k.downcase)
        end
        unless findings.empty?
          part_pos = findings.index "Part"
          do_splice = !findings.includes?("Part") && !findings.empty? && !arg_name.downcase.includes?("or")
          findings.delete_at(part_pos.not_nil!) if do_splice
          param_type =
            safe_renamed_instance(findings.find { |found| found.downcase == arg_name.downcase }) ||
            findings.map { |found| found.downcase == arg_name.downcase }
        end
      end
      args << "#{arg_name || "arg#{i}"} #{!param_type.nil? ? ": #{param_type}#{optional ? "?" : ""}" : ""}"
    end
    args.join ", "
  end

  private def generate_callback(callback : API::Callback, class_name : String, e)
    description = (callback.description || "").trim != "" ?
      callback.description
      : @metadata.not_nil!.get_callback_desc(class_name, callback.name)

    write "#{callback.name} : #{callback.parameters.map { |param| safe_value_type param.type }.join ", "} -> Nil"
  end

  private def generate_event(event : API::Event, class_name : String)

  end

  private def generate_function(function : API::Function, class_name : String)

  end

  private def generate_property(property : API::Property, class_name : String)

  end

  # Generates each class in `rbx_classes`
  private def generate_classes(rbx_classes : Array(API::Class))
    write "# GENERATED ROBLOX INSTANCE CLASSES"
    write ""
    rbx_classes.each { |rbx_class| generate_class rbx_class }
  end

  # Appends header and dependencies
  private def generate_header
    write "# THIS FILE IS AUTOMATICALLY GENERATED AND SHOULD NOT BE EDITED MANUALLY!"
    write ""
    write "require \"./#{@lower_security}.d\"" unless @lower_security.nil?
    # write "require \"./roblox.d\""
    write "require \"./Enums.d\""
    write ""
  end

  def generate(rbx_classes : Array(API::Class))
    rbx_classes.each do |rbx_class|
      class_name = rbx_class.name
      rbx_class.subclasses = [] of String

      @class_refs[class_name] = rbx_class
      superclass : API::Class? = rbx_class.superclass != ROOT_CLASS_NAME ? @class_refs[rbx_class.superclass] : nil
      superclass.subclasses.not_nil! << class_name unless superclass.nil? || superclass.subclasses.nil?
    end

    classes_to_generate = rbx_classes.select { |rbx_class| should_generate_class?(rbx_class) }
    generate_header
    generate_instances_tables classes_to_generate.select { |rbx_class| @defined_class_names.includes?(rbx_class.name) }
    generate_classes rbx_classes
    write_file
  end
end
