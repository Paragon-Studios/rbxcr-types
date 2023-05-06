require "json"

module API
  class Dump
    include JSON::Serializable

    @[JSON::Field(key: "Classes")]
    getter classes : Array(Class)

    @[JSON::Field(key: "Enums")]
    getter enums : Array(Enum)

    @[JSON::Field(key: "Version")]
    getter version : Float64
  end

  class Enum
    include JSON::Serializable

    @[JSON::Field(key: "Items")]
    getter items : Array(EnumItem)

    @[JSON::Field(key: "Name")]
    getter name : String
  end

  class EnumItem
    include JSON::Serializable

    @[JSON::Field(key: "LegacyNames", emit_null: true)]
    getter legacy_names : Array(String)?

    @[JSON::Field(key: "Name")]
    getter name : String

    @[JSON::Field(key: "Value")]
    getter value : Float64
  end

  class ClassTags
    include JSON::Serializable

    @[JSON::Field(key: "PreferredDescriptorName", emit_null: true)]
    getter preferred_descriptor_name : String?

    @[JSON::Field(key: "ThreadSafety", emit_null: true)]
    getter thread_safety : String?
  end

  alias Member = Property | Function | Event | Callback
  class Class
    include JSON::Serializable

    @[JSON::Field(key: "Members")]
    getter members : Array(Member)

    @[JSON::Field(key: "MemoryCategory")]
    getter member_category : String

    @[JSON::Field(key: "Tags", emit_null: true)]
    getter tags : Array(String | ClassTags)?

    @[JSON::Field(key: "ThreadSafety", emit_null: true)]
    getter thread_safety : String?

    @[JSON::Field(key: "Name")]
    getter name : String

    @[JSON::Field(key: "Superclass")]
    getter superclass : String

    @[JSON::Field(key: "Subclasses", emit_null: true)]
    getter subclasses : Array(String)?

    @[JSON::Field(key: "Description", emit_null: true)]
    getter description : String?
  end

  class MemberBase
    include JSON::Serializable

    @[JSON::Field(key: "MemberType")]
    getter member_type : String

    @[JSON::Field(key: "Name")]
    getter name : String

    @[JSON::Field(key: "Security")]
    getter security : String | Security

    @[JSON::Field(key: "Tags", emit_null: true)]
    getter tags : Array(String | ClassTags)?

    @[JSON::Field(key: "Description", emit_null: true)]
    getter description : String?
  end

  class Event < MemberBase
    include JSON::Serializable

    @[JSON::Field(key: "Parameters")]
    getter parameters : Array(Parameter)
  end

  class Callback < MemberBase
    include JSON::Serializable

    @[JSON::Field(key: "Parameters")]
    getter parameters : Array(Parameter)
  end

  class Function < MemberBase
    include JSON::Serializable

    @[JSON::Field(key: "Parameters")]
    getter parameters : Array(Parameter)

    @[JSON::Field(key: "ReturnType")]
    getter return_type : ValueType
  end

  class Property < MemberBase
    include JSON::Serializable

    @[JSON::Field(key: "Category")]
    getter category : String

    @[JSON::Field(key: "Serialization")]
    getter serialization : Serialization

    @[JSON::Field(key: "ValueType")]
    getter value_type : ValueType
  end

  class Serialization
    include JSON::Serializable

    @[JSON::Field(key: "CanLoad")]
    getter can_load : Bool

    @[JSON::Field(key: "CanSave")]
    getter can_save : Bool
  end

  class ValueType
    include JSON::Serializable

    @[JSON::Field(key: "Category")]
    getter category : String

    @[JSON::Field(key: "Name")]
    getter name : String
  end

  class Security
    include JSON::Serializable

    @[JSON::Field(key: "Read")]
    getter read : String

    @[JSON::Field(key: "Write")]
		getter write : String
  end

  class Parameter
    include JSON::Serializable

    @[JSON::Field(key: "Name")]
    getter name : String

    @[JSON::Field(key: "Type")]
    getter type : ValueType

    @[JSON::Field(key: "Default", emit_null: true)]
    getter default : String?
  end
end
