module Rbx
  alias Tweenable = Float64 | Int64 | Float32 | Int32 | Bool | CFrame | Rect | Color3 | UDim | UDim2 | Vector2 | Vector2int16 | Vector3
  alias AttributeValue = String | Bool | Float64 | Float32 | Int64 | Int32 | UDim | UDim2 | BrickColor | Color3 | Vector2 | Vector3 | CFrame | NumberSequence | ColorSequence | NumberRange | Rect | Font
  alias EquippedEmotes = Array(EquippedEmote)
  alias HttpHeaders = Hash(String, String)

  class TweenInfo
    getter time : Float64
    getter easing_style : Enum::EasingStyle
    getter easing_direction : Enum::EasingDirection
    getter repeat_count : Int32
    getter reverses : Bool
    getter delay_time : Float64

    def initialize(
      @time : Float64?,
      @easing_style : Enum::EasingStyle?,
      @easing_direction : Enum::EasingDirection?,
      @repeat_count : Int32?,
      @reverses : Bool?,
      @delay_time : Float64?
    )
    end
  end

  class DateTime
    # Unix timestamp in seconds
    getter unix_timestamp : Int64
    # Unix timestamp in milliseconds
    getter unix_timestamp_millis : Int64

    # Converts the value of this DateTime object to Universal Coordinated Time (UTC)
    def to_universal_time : TimeValueTable; end
    # Converts the value of this DateTime object to local time
    def to_local_time : TimeValueTable; end
    # Returns a string representation of the date in ISO format (YYYY-MM-DD)
    def to_iso_date : String; end
    # Formats the date and time in UTC using the specified format string and locale
    def format_universal_time(format : String, locale : String) : String; end
    # Formats the date and time in local time using the specified format string and locale
    def format_local_time(format : String, locale : String) : String; end

    def initialize(@unix_timestamp, @unix_timestamp_millis)
    end

    def self.now : DateTime; end
    def self.from_iso_date(iso_date : String) : DateTime?; end
    def self.from_unix_timestamp(unix_timestamp : Int64) : DateTime; end
    def self.from_unix_timestamp_millis(unix_timestamp_millis : Int64) : DateTime; end
    def self.from_universal_time(
      year : Int32?,
      month : Int8?,
      day : Int8?,
      hour : Int8?,
      minute : Int8?,
      second : Int8?,
      millisecond : Int32?
    ) : DateTime; end
    def self.from_local_time(
      year : Int32?,
      month : Int8?,
      day : Int8?,
      hour : Int8?,
      minute : Int8?,
      second : Int8?,
      millisecond : Int32?
    ) : DateTime; end
  end

  struct TimeValueTable
    # Range: 1400-9999
    getter year : Int32
    # Range: 1-12
    getter month : Int8
    # Range: 1-31
    getter day : Int8
    # Range: 0-23
    getter hour : Int8
    # Range: 0-59
    getter minute : Int8
    # Range: 0-60
    # Usually 0–59, sometimes 60 to accommodate leap seconds in certain systems.
    getter second : Int8
    # Range: 0-999
    getter millisecond : Int32
  end

  class Region3
    property cframe : CFrame;
    property size : Vector3;
    def expand_to_grid(resolution : Float64) : Region3; end
  end

  class Region3int16
    property min : Vector3int16;
    property max : Vector3int16;
  end

  class Ray
    getter origin : Vector3
    getter direction : Vector3
    getter unit : Ray

    def closest_point(point : Vector3) : Vector3
    end
    def distance(point : Vector3) : Float64
    end

    def initialize(*ids : Enum::NormalId)
    end
  end

  class PhysicalProperties
    property density : Float64;
    property friction : Float64;
    property elasticity : Float64;
    property friction_weight : Float64;
    property elasticity_weight : Float64;

    def initialize(
      density : Float64,
      friction : Float64,
      elasticity : Float64,
      friction_weight : Float64,
      elasticity_weight : Float64,
    )
    end
  end

  class Faces
    getter top : Bool
    getter bottom : Bool
    getter left : Bool
    getter right : Bool
    getter back : Bool
    getter front : Bool

    def initialize(*ids : Enum::NormalId)
      @top = true
      @bottom = true
      @left = true
      @right = true
      @back = true
      @front = true
    end
  end

  class Axes
    getter x : Bool
    getter y : Bool
    getter z : Bool
    getter top : Bool
    getter bottom : Bool
    getter left : Bool
    getter right : Bool
    getter back : Bool
    getter front : Bool

    def initialize(*axes : Enum::NormalAxis | Enum::NormalId)
      @x = true
      @y = true
      @z = true
      @top = true
      @bottom = true
      @left = true
      @right = true
      @back = true
      @front = true
    end
  end

  class Font
    getter bold : Bool
    getter style : Enum::FontStyle
    getter family : String
    getter weight : Enum::FontWeight

    def initialize(@family : String, @weight : Enum::FontWeight? = nil, @style : Enum::FontStyle? = nil)
      @bold = @weight == Enum::FontWeight::Bold || @weight == Enum::FontWeight::SemiBold || @weight == Enum::FontWeight::Black
    end
  end

  class NumberRange
    getter min : Float64
    getter max : Float64

    def initialize(value : Float64)
    end

    def initialize(minimum : Float64, maximum : Float64)
    end
  end

  class BrickColor
    getter number : Int32
    getter name : String
    getter color : Color3
    getter r : Float64
    getter g : Float64
    getter b : Float64

    def initialize(@number : Int32)
      @r = 0
      @g = 0
      @b = 0
      @color = Color3.new
      @name = ""
    end

    def initialize(@color : Color3)
      @r, @g, @b = @color
      @number = 0
      @name = ""
    end

    def initialize(@r : Int8, @g : Int8, @b : Int8)
      @color = Color3.from_rgb(@r, @g, @b)
      @number = 0
      @name = ""
    end

    def self.random : BrickColor; end
    def self.white : BrickColor; end
    def self.gray : BrickColor; end
    def self.dark_gray : BrickColor; end
    def self.black : BrickColor; end
    def self.red : BrickColor; end
    def self.yellow : BrickColor; end
    def self.green : BrickColor; end
    def self.blue : BrickColor; end
  end

  class NumberSequence
    getter keypoints : Array(NumberSequenceKeypoint)

    def initialize(n : Number)
    end

    def initialize(n0 : Number, n1 : Number)
    end

    def initialize(keypoints : Array(NumberSequenceKeypoint))
    end
  end

  class NumberSequenceKeypoint
    getter envelope : Float64
    getter time : Float64
    getter value : Float64

    def initialize(time : Number, value : Number, envelope = nil)
    end
  end

  NumberSequenceConstructor = NumberSequence
  NumberSequenceKeypointConstructor = NumberSequenceKeypoint


  class ColorSequence
    getter keypoints : Array(ColorSequenceKeypoint)

    def initialize(color : Color3)
      @keypoints = [ColorSequenceKeypoint.new(color)]
    end
    def initialize(c0 : Color3, c1 : Color3)
      @keypoints = [ColorSequenceKeypoint.new(c0, c1)]
    end
    def initialize(@keypoints : Array(ColorSequenceKeypoint))
    end
  end

  class ColorSequenceKeypoint
    getter time : Float64
    getter value : Color3

    def initialize(@time : Float64, @value : Color3)
    end
  end

  class Vector2
    getter zero : Vector2
    getter one : Vector2
    getter x_axis : Vector2
    getter y_axis : Vector2

    property x : Float64
    property y : Float64
    getter unit : Vector2
    getter magnitude : Float64

    def dot(other : Vector2) : Float64; end
    def lerp(goal : Vector2, alpha : Float64) : Vector2; end
    def cross(other : Vector2) : Float64; end
    def min(vectors : Array(Vector2)) : Vector2; end
    def max(vectors : Array(Vector2)) : Vector2; end
  end

  class Vector2int16
    getter zero : Vector2int16
    getter one : Vector2int16
    getter x_axis : Vector2int16
    getter y_axis : Vector2int16

    property x : Int16
    property y : Int16

    def initialize(x : Int16? = nil, y : Int16? = nil); end
  end

  class Vector3
    getter zero : Vector3
    getter one : Vector3
    getter x_axis : Vector3
    getter y_axis : Vector3
    getter z_axis : Vector3

    property x : Float64
    property y : Float64
    property z : Float64
    getter unit : Vector3
    getter magnitude : Float64

    def initialize(x : Float64? = nil, y : Float64? = nil, z : Float64? = nil); end

    def lerp(goal : Vector3, alpha : Float64) : Vector3; end
    def dot(other : Vector3) : Float64; end
    def cross(other : Vector3) : Vector3; end
    def fuzzy_eq(other : Vector3, epsilon : Float64? = nil) : Bool; end
    def min(vectors : Array(Vector3)) : Vector3; end
    def max(vectors : Array(Vector3)) : Vector3; end
    def angle(other : Vector3, axis : Vector3? = nil) : Float64; end
  end

  class Vector3int16
    getter zero : Vector3int16
    getter one : Vector3int16
    getter x_axis : Vector3int16
    getter y_axis : Vector3int16
    getter z_axis : Vector3int16

    property x : Int16
    property y : Int16
    property z : Int16

    def initialize(x : Int16? = nil, y : Int16? = nil, z : Int16? = nil); end
  end

  class UDim
    property scale : Float64
    property offset : Float64

    def initialize(scale : Float64? = nil, offset : Float64? = nil)
    end
  end

  class UDim2
    property x : UDim
    property y : UDim
    property width : UDim
    property height : UDim

    def initialize(x_scale : Float64, x_offset : Float64, y_scale : Float64, y_offset : Float64)
    end
    def initialize(x_dim : UDim, y_dim : UDim)
    end
    def initialize
    end

    def self.from_offset(x : Float64? = nil, y : Float64? = nil) : UDim2
    end
    def self.from_scale(x : Float64? = nil, y : Float64? = nil) : UDim2
    end

    def lerp(goal : UDim2, alpha : Float64) : UDim2
    end
  end


  class Rect
    property min : Vector2
    property max : Vector2
    property width : Float64
    property height : Float64

    def initialize(min : Vector2? = nil, max : Vector2? = nil)
    end
    def initialize(min_x : Float64, min_y : Float64, max_x : Float64, max_y : Float64)
    end
  end

  class Color3
    def self.from_rgb(r : Int32 = 0, g : Int32 = 0, b : Int32 = 0) : Color3
    end
    def self.from_hsv(hue : Float64, sat : Float64, val : Float64) : Color3
    end
    def self.to_hsv(color : Color3) : Tuple(Float64, Float64, Float64)
    end
    def self.from_hex(hex : String) : Color3
    end

    def initialize(@red : Float64 = 0.0, @green : Float64 = 0.0, @blue : Float64 = 0.0)
    end
  end

  class CFrame
    def self.identity : CFrame
      CFrame.new(
        Vector3.new(0, 0, 0),
        CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
      )
    end

    getter position : Vector3
    getter rotation : CFrame
    getter x : Float64
    getter y : Float64
    getter z : Float64
    getter look_vector : Vector3
    getter right_vector : Vector3
    getter up_vector : Vector3
    getter x_vector : Vector3
    getter y_vector : Vector3
    getter z_vector : Vector3

    def initialize(@position : Vector3, @rotation : CFrame)
      @x, @y, @z = @position
      @look_vector = Vector3.new
      @right_vector = Vector3.new
      @up_vector = Vector3.new
      @x_vector = Vector3.new
      @y_vector = Vector3.new
      @z_vector = Vector3.new
    end
    def inverse : CFrame
    end
    def lerp(goal : CFrame, alpha : Float64) : CFrame
    end
    def orthonormalize : CFrame
    end
    def to_world_space(cf : CFrame) : CFrame
    end
    def to_object_space(cf : CFrame) : CFrame
    end
    def point_to_world_space(v3 : Vector3) : Vector3
    end
    def point_to_object_space(v3 : Vector3) : Vector3
    end
    def vector_to_world_space(v3 : Vector3) : Vector3
    end
    def vector_to_object_space(v3 : Vector3) : Vector3
    end
    def get_components : Tuple(Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64)
    end
    def to_euler_angles_xyz : Tuple(Float64, Float64, Float64)
    end
    def to_euler_angles_yxz : Tuple(Float64, Float64, Float64)
    end
    def to_orientation : Tuple(Float64, Float64, Float64)
    end
    def to_axis_angle : Tuple(Vector3, Float64)
    end
  end

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

  abstract struct BaseAccessoryInfo
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

  abstract struct ProductInfo
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

  enum AssetTypeId
    Image = 1
    TeeShirt = 2
    Audio = 3
    Mesh = 4
    Lua = 5
    Hat = 8
    Place = 9
    Model = 10
    Shirt = 11
    Pants = 12
    Decal = 13
    Head = 17
    Face = 18
    Gear = 19
    Badge = 21
    Animation = 24
    Torso = 27
    RightArm = 28
    LeftArm = 29
    LeftLeg = 30
    RightLeg = 31
    Package = 32
    GamePass = 34
    Plugin = 38
    MeshPart = 40
    HairAccessory = 41
    FaceAccessory = 42
    NeckAccessory = 43
    ShoulderAccessory = 44
    FrontAccessory = 45
    BackAccessory = 46
    WaistAccessory = 47
    ClimbAnimation = 48
    DeathAnimation = 49
    FallAnimation = 50
    IdleAnimation = 51
    JumpAnimation = 52
    RunAnimation = 53
    SwimAnimation = 54
    WalkAnimation = 55
    PoseAnimation = 56
    EarAccessory = 57
    EyeAccessory = 58
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
