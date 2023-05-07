require "./reflection_metadata"
require "fs"

class Generator
  @stream : FS::WriteStream
  @indent = ""

  def initialize(file_path : String, @metadata : ReflectionMetadata? = nil)
    FS.ensure_file(file_path)
    @stream = FS.create_write_stream(file_path)
  end

  def push_indent
    @indent += "\t"
  end

  def pop_indent
    @indent = @indent[1..-1]
  end

  def write(line : String)
    @stream.write("#{@indent}#{line unless line.empty?}\n")
  end
end
