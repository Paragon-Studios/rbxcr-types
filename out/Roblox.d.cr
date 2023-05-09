module Rbx
  Tweenable = number | boolean | CFrame | Rect | Color3 | UDim | UDim2 | Vector2 | Vector2int16 | Vector3
  EquippedEmotes = Array(EquippedEmote)
  HttpHeaders = Hash(String, String)

  struct RequestAsyncRequest
    getter success : Bool
    getter status_code : Int32
    getter status_message : String
    getter headers : HttpHeaders
    getter body : String
  end

  private struct EquippedEmote
    getter name : String
    getter slot : Int8
  end

  struct UserInfo
    getter id : Int64
    getter username : String
    getter display_name : String
  end

  private struct GroupOwner
    getter id : Int64
    getter name : String
  end

  private struct GroupRole
    getter name : String
    getter rank : Int8
  end

  struct GroupInfo
    getter id : Int64
    getter name : String
    getter owner : GroupOwner
    getter emblem_url : String
    getter description : String
    getter roles : Array(GroupRole)
  end

  struct GetGroupsAsyncResult
    getter id : Int64
    getter name : String
    getter emblem_url : String
    getter description : String
    getter rank : Int8
    getter role : String
    getter is_primary : Bool
    getter is_in_clan : Bool
  end

  struct SetInfo
    property asset_set_id : String
    property category_id : String
    property creator_name : String
    property description : String
    property image_asset_id : String
    property name : String
    property set_type : String
  end

  struct CollectionInfo
    property asset_id : String
    property asset_set_id : String
    property asset_version_id : String
    property is_trusted : Bool
    property name : String
    property creator_name : String
  end

  struct BaseAccessoryInfo
    property asset_id : Int32
    property accessory_type : Enum::AccessoryType
  end

  struct RigidAccessoryInfo < BaseAccessoryInfo
    property is_layered = false
  end

  struct LayeredAccessoryInfo < BaseAccessoryInfo
    property is_layered = true
    property order : Int32
    property puffiness : Int32?
  end

  AccessoryInfo = RigidAccessoryInfo | LayeredAccessoryInfo

  private struct FreeSearchResultResult
    property asset_id : String
    property asset_version_id : String
    property creator_name : String
    property name : String
  end

  struct FreeSearchResult
    property current_start_index : String
    property results : Array(FreeSearchResultResult)
    property total_count : String
  end

  struct LocalizationEntry
    property key : String
    property source : String
    property context : String
    property example : String
    property values : Hash(String, String)
  end

  struct LogInfo
    property message : String
    property message_type : Enum::MessageType
    property timestamp : Int32
  end

  struct ReceiptInfo
    property player_id : Int32
    property place_id_where_purchased : Int32
    property purchase_id : String
    property product_id : Int32
    property currency_type : Enum::CurrencyType
    property currency_spent : Int32
  end

  private struct ProductCreator
    property creator_type : String?
    property creator_target_id : Int32
    property name : String?
  end

  struct ProductInfo
    property name : String
    property description : String?
    property price_in_robux : Int32?
    property created : String
    property updated : String
    property is_for_sale : Bool
    property sales : Int32?
    property product_id : Int32
    property creator : ProductCreator
    property targetId : Int32
  end

  struct AssetProductInfo < ProductInfo
    property product_type = "User Product"
    property asset_id : Int32
    property asset_type_id : AssetTypeId
    property is_new : Bool
    property is_limited : Bool
    property is_limited_unique : Bool
    property is_public_domain : Bool
    property remaining : Int32?
    property content_rating_type_id : Int32
    property minimum_membership_level : Int32
  end

  struct DeveloperProductInfo < ProductInfo
    property product_type = "Developer Product"
    property icon_image_asset_id : Int32
  end

  struct GamePassProductInfo < ProductInfo
    property product_type = "Game Pass"
    property icon_image_asset_id : Int32
  end

  struct SubscriptionProductInfo < ProductInfo
    property product_type = "Subscription"
  end

  struct BadgeInfo
    property name : String
    property description : String
    property icon_image_id : Int32
    property is_enabled : Bool
  end

  struct ScriptConnection
    property connected : Bool
    def disconnect
    end
  end

  struct ScriptSignal(CallbackT)
    def connect(&callback : CallbackT) : ScriptConnection
    end
    def connect_parallel(&callback : CallbackT) : ScriptConnection
    end
    def once(&callback : CallbackT) : ScriptConnection
    end
    def wait() : Tuple(_)
    end
  end
end
