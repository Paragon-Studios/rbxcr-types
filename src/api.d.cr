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
  end

  class Enum
    include JSON::Serializable

    @[JSON::Field(key: "Items")]
    property items : Array(EnumItem)

    @[JSON::Field(key: "Name")]
    property name : String
  end

  class EnumItem
    include JSON::Serializable

    @[JSON::Field(key: "LegacyNames", emit_null: true)]
    property legacy_names : Array(String)?

    @[JSON::Field(key: "Name")]
    property name : String

    @[JSON::Field(key: "Value")]
    property value : Float64
  end

  class ClassTags
    include JSON::Serializable

    @[JSON::Field(key: "PreferredDescriptorName", emit_null: true)]
    property preferred_descriptor_name : String?

    @[JSON::Field(key: "ThreadSafety", emit_null: true)]
    property thread_safety : String?
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
  end

  class MemberBase
    include JSON::Serializable

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
  end

  class Event < MemberBase
    include JSON::Serializable

    @[JSON::Field(key: "Parameters")]
    property parameters : Array(Parameter)
  end

  class Callback < MemberBase
    include JSON::Serializable

    @[JSON::Field(key: "Parameters")]
    property parameters : Array(Parameter)
  end

  class Function < MemberBase
    include JSON::Serializable

    @[JSON::Field(key: "Parameters")]
    property parameters : Array(Parameter)

    @[JSON::Field(key: "ReturnType")]
    property return_type : ValueType
  end

  class Property < MemberBase
    include JSON::Serializable

    @[JSON::Field(key: "Category")]
    property category : String

    @[JSON::Field(key: "Serialization")]
    property serialization : Serialization

    @[JSON::Field(key: "ValueType")]
    property value_type : ValueType
  end

  class Serialization
    include JSON::Serializable

    @[JSON::Field(key: "CanLoad")]
    property can_load : Bool

    @[JSON::Field(key: "CanSave")]
    property can_save : Bool
  end

  class ValueType
    include JSON::Serializable

    @[JSON::Field(key: "Category")]
    property category : String

    @[JSON::Field(key: "Name")]
    property name : String
  end

  class Security
    include JSON::Serializable

    @[JSON::Field(key: "Read")]
    property read : String

    @[JSON::Field(key: "Write")]
		property write : String
  end

  class Parameter
    include JSON::Serializable

    @[JSON::Field(key: "Name")]
    property name : String

    @[JSON::Field(key: "Type")]
    property type : ValueType

    @[JSON::Field(key: "Default", emit_null: true)]
    property default : String?
  end
end
