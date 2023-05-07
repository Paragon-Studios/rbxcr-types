# generates documentation
module ClassInformation
  private class Summarized
    getter summary : String
  end

  private class Argument < Summarized
    getter name : String
  end

  class CodeSample
    getter display_title : String
    getter code_summary : String
    getter code_sample : String
  end

  class Member
    getter title : String
    getter description : String
    getter code_sample : Array(CodeSample)?
  end

  private class Property < Member; end

  private class Event < Member
    getter argument : Array(Argument)
  end

  private class Method < Member
    getter returns : Array(Summarized)
  end

  private class Callback < Method; end

  class ClassDescription < Member
    getter "property" : Array(Property)
    getter function : Array(Method)
    getter event : Array(Event)
    getter callback : Array(Callback)
  end
end
