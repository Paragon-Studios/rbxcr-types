module Rbx
  Tweenable = number | boolean | CFrame | Rect | Color3 | UDim | UDim2 | Vector2 | Vector2int16 | Vector3
  EquippedEmotes = Array(EquippedEmote)
  HttpHeaders = Hash(String, String)

  private class EquippedEmote
    getter name : String
    getter slot : Int8
  end

  class UserInfo
    getter id : Int64
    getter username : String
    getter display_name : String
  end

  private class GroupOwner
    getter id : Int64
    getter name : String
  end

  private class GroupRole
    getter name : String
    getter rank : Int8
  end

  class GroupInfo
    getter id : Int64
    getter name : String
    getter owner : GroupOwner
    getter emblem_url : String
    getter description : String
    getter roles : Array(GroupRole)
  end

  class GetGroupsAsyncResult
    getter id : Int64
    getter name : String
    getter emblem_url : String
    getter description : String
    getter rank : Int8
    getter role : String
    getter is_primary : Bool
    getter is_in_clan : Bool
  end

  class ScriptConnection
    def disconnect
    end
  end
  class ScriptSignal(CallbackT)
    def connect(&callback : CallbackT) : ScriptConnection
    end
    def fire(*params : Array(_)) : ScriptConnection
    end
  end
end
