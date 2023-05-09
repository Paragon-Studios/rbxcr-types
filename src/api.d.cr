require "json"

module API
  class Dump
    include JSON::Serializable

    @[JSON::Field(key: "Classes")]
    property classes : Array(Class)

    @[JSON::Field(key: "Enums")]
    property enums : Array(Enum)

    @[JSON::Field(key: "Version")]
    property version : Float64

    def to_s
      "API::Dump<classes: #{@classes}, enums: #{@enums}, version: #{@version}>"
    end
  end

  class Enum
    include JSON::Serializable

    @[JSON::Field(key: "Items")]
    property items : Array(EnumItem)

    @[JSON::Field(key: "Name")]
    property name : String

    def to_s
      "API::Enum<name: #{@name}, items: #{@items}>"
    end
  end

  class EnumItem
    include JSON::Serializable

    @[JSON::Field(key: "LegacyNames", emit_null: true)]
    property legacy_names : Array(String)?

    @[JSON::Field(key: "Name")]
    property name : String

    @[JSON::Field(key: "Value")]
    property value : Int32

    def to_s
      "API::EnumItem<name: #{@name}, value: #{@value}, legacy_names: #{@legacy_names}>"
    end
  end

  class ClassTags
    include JSON::Serializable

    @[JSON::Field(key: "PreferredDescriptorName", emit_null: true)]
    property preferred_descriptor_name : String?

    @[JSON::Field(key: "ThreadSafety", emit_null: true)]
    property thread_safety : String?

    def to_s
      "API::ClassTags<preferred_descriptor_name: #{@preferred_descriptor_name}, thread_safety: #{@thread_safety}>"
    end
  end

  alias Member = Property | Function | Event | Callback
  class Class
    include JSON::Serializable

    @[JSON::Field(key: "Members")]
    property members : Array(Member)

    @[JSON::Field(key: "MemoryCategory")]
    property member_category : String

    @[JSON::Field(key: "Tags", emit_null: true)]
    property tags : Array(String | ClassTags)?

    @[JSON::Field(key: "ThreadSafety", emit_null: true)]
    property thread_safety : String?

    @[JSON::Field(key: "Name")]
    property name : String

    @[JSON::Field(key: "Superclass")]
    property superclass : String

    @[JSON::Field(key: "Subclasses", emit_null: true)]
    property subclasses : Array(String)?

    @[JSON::Field(key: "Description", emit_null: true)]
    property description : String?

    def to_s
      "API::Class<name: #{@name}, member_category: #{@member_category}, members: #{@members}, tags: #{@tags}, description: #{@description}, thread_safety: #{@thread_safety}, superclass: #{@superclass}, subclasses: #{@subclasses}>"
    end
  end

  abstract class MemberBase
    include JSON::Serializable

    use_json_discriminator "MemberType", {
      Callback: Callback,
      Event: Event,
      Function: Function,
      Property: Property
    }

    @[JSON::Field(key: "MemberType")]
    property member_type : String

    @[JSON::Field(key: "Name")]
    property name : String

    @[JSON::Field(key: "Security")]
    property security : String | Security

    @[JSON::Field(key: "Tags", emit_null: true)]
    property tags : Array(String | ClassTags)?

    @[JSON::Field(key: "Description", emit_null: true)]
    property description : String?

    def to_s
      "API::MemberBase<member_type: #{@member_type}, name: #{@name}, security: #{@security}, tags: #{@tags}, description: #{@description}>"
    end
  end

  class Callback < MemberBase
    @[JSON::Field(key: "Parameters")]
    property parameters : Array(Parameter)

    def to_s
      "API::Callback<member_type: Callback, name: #{@name}, security: #{@security}, tags: #{@tags}, description: #{@description}, parameters: #{@parameters}>"
    end
  end

  class Event < Callback
    def to_s
      "API::Event<member_type: Event, name: #{@name}, security: #{@security}, tags: #{@tags}, description: #{@description}, parameters: #{@parameters}>"
    end
  end

  class Function < Callback
    @[JSON::Field(key: "ReturnType")]
    property return_type : ValueType

    def to_s
      "API::Function<member_type: Function, name: #{@name}, security: #{@security}, tags: #{@tags}, description: #{@description}, parameters: #{@parameters}, return_type: #{@return_type}>"
    end
  end

  class Property < MemberBase
    @[JSON::Field(key: "Category")]
    property category : String
    @[JSON::Field(key: "Default")]
    property default : String
    @[JSON::Field(key: "Serialization")]
    property serialization : Serialization
    @[JSON::Field(key: "ThreadSafety")]
    property thread_safety : String
    @[JSON::Field(key: "ValueType")]
    property value_type : ValueType

    def to_s
      "API::Property<member_type: Function, name: #{@name}, security: #{@security}, tags: #{@tags}, description: #{@description}, category: #{@category}, serialization: #{@serialization}, value_type: #{@value_type}>"
    end
  end

  class Serialization
    include JSON::Serializable

    @[JSON::Field(key: "CanLoad")]
    property can_load : Bool
    @[JSON::Field(key: "CanSave")]
    property can_save : Bool

    def to_s
      "API::Serialization<can_load: #{@can_load}, can_save: #{@can_save}>"
    end
  end

  class ValueType
    include JSON::Serializable

    @[JSON::Field(key: "Name", emit_null: true)]
    property name : String?
    @[JSON::Field(key: "Category")]
    property category : String

    def to_s
      "API::ValueType<name: #{@name}, category: #{@category}>"
    end
  end

  class Security
    include JSON::Serializable

    @[JSON::Field(key: "Read")]
    property read : String
    @[JSON::Field(key: "Write")]
		property write : String

    def as_hash
      {
        "read" => @read,
        "write" => @write
      }
    end

    def to_s
      "API::Security<read: #{@read}, write: #{@write}>"
    end
  end

  class Parameter
    include JSON::Serializable

    @[JSON::Field(key: "Name")]
    property name : String
    @[JSON::Field(key: "Type")]
    property type : ValueType
    @[JSON::Field(key: "Default", emit_null: true)]
    property default : String?

    def to_s
      "API::Parameter<name: #{@name}, type: #{@type}, default: #{@default}>"
    end
  end
end
