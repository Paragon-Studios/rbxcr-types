require "./reflection_metadata"
require "file_utils"
require "io"

class Generator
  @stream = IO::Memory.new
  @indent = ""

  def initialize(
    @file_path : String,
    @metadata : ReflectionMetadata? = nil
  ) end

  protected def write_file
    FileUtils.mkdir_p File.dirname(@file_path)
    File.write @file_path, @stream.to_s
  end

  protected def write(line : String)
    @stream << "#{@indent}#{line unless line.empty?}\n"
  end

  protected def push_indent
    @indent += "\t"
  end

  protected def pop_indent
    @indent = @indent[1..-1]
  end
end
