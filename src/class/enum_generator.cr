require "../api.d"
require "./generator"

class EnumGenerator < Generator
  def generate(rbx_enums : Array(API::Enum)) : Nil
    write "// THIS FILE IS GENERATED AUTOMATICALLY AND SHOULD NOT BE EDITED BY HAND!"
    write ""
    write "// GENERATED ROBLOX ENUMS"
    write ""
    write "module EnumItem; end"
    write ""
    write "struct Enum"
    push_indent

    rbx_enums.each do |rbx_enum|
      enum_type_name = rbx_enum.name
      enum_type_items = rbx_enum.items
      enum_item_names = [] of String

      write "module #{enum_type_name}"
      push_indent

      write "include EnumItem"
      enum_type_items.each do |enum_item|
        enum_item_name = enum_item.name
        enum_item_value = enum_item.value
        enum_item_legacy_names = enum_item.legacy_names

        enum_item_names << enum_item_name
        write "Name \"#{enum_item_name}\""
        write "Value #{enum_item_value}"
        write "EnumType = #{enum_type_name}"
        write ""
        (enum_item_legacy_names || [] of String).each do |enum_item_legacy_name|
          if !enum_item_legacy_name.includes?(" ") && !enum_type_items.any? { |i| i.name == enum_item_legacy_name }
            write "# @deprecated renamed to #{enum_item_name}"
            write "#{enum_item_legacy_name} = #{enum_item_name}"
          end
        end
        write ""
      end

      enum_union = !enum_item_names.size.empty? ?
        (enum_item_names.map { |enum_item_name| "#{enum_item_name}" }.join " | ")
        : "Nil"

      write ""
    end

    pop_indent
    write "end"
  end
end
