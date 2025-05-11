class_name Global

static var selected_card: CardData = null
static var selected_structure: Structure = null
static var shape := Enums.CursorShape.Smart
static var rotate = 0
static var flip = 0
 
static var FARM_TOPLEFT = Vector2(1, 1)
static var FARM_BOTRIGHT = Vector2(6, 6)

static var ENERGY_FRAGMENTS: int = 0
static var SCROLL_FRAGMENTS: int = 0
static var MAX_HAND_SIZE: int = 10

static var BLIGHT_TILES_THREATENED = 4
static var BLIGHT_FLAG_PIERCING = false
static var BLIGHT_FLAG_THREATEN_GROWING = false
static var BLIGHT_TARGET_MULTIPLIER: float = 1.0
static var DESTROY_TILES_THIS_TURN: int = 1
static var IRRIGATE_PROTECTED = false
static var MAX_BLIGHT: int = 5
static var MAX_HEALTH: int = 100
static var ACORNS: int = 0
static var ACORN_BONUS: float = 0.0

static var MANA_TARGET_LOCATION_YELLOW: Vector2 = Vector2(628, 442)
static var MANA_TARGET_LOCATION_PURPLE: Vector2 = Vector2(1461, 456)

static var GILDED_ROSE_TALLY: float = 0.0
static var WATERED_MULTIPLIER = 0.4

static var DIFFICULTY: int = 0
static var FINAL_YEAR = 8
static var SPRING_WEEK = 1
static var SUMMER_WEEK = 5
static var FALL_WEEK = 9
static var WINTER_WEEK = 13
static var FINAL_WEEK = 13

static var FARM_TYPE = "FOREST"
static var LUNAR_FARM = false
static var MAGE: String = ""
static var WILDERNESS_PLANT = null

static var END_TURN_DISCARD = true
static var BLOCK_RITUAL = false
static var BLOCK_GROW = false
static var ALL_WATERED = true

static var pressed: bool = false
static var pressed_time: float = 0.0
static var MOBILE: bool = false

static var click_callbacks = []

static func reset():
	selected_card = null
	selected_structure = null
	shape = Enums.CursorShape.Square
	rotate = 0
	flip = 0
	FARM_TOPLEFT = Vector2(1, 1)
	FARM_BOTRIGHT = Vector2(6, 6)
	ENERGY_FRAGMENTS = 0
	SCROLL_FRAGMENTS = 0
	BLIGHT_TILES_THREATENED = 4
	BLIGHT_FLAG_PIERCING = false
	BLIGHT_FLAG_THREATEN_GROWING = false
	BLIGHT_TARGET_MULTIPLIER = 1.0
	DESTROY_TILES_THIS_TURN = 1
	FINAL_YEAR = 8
	SPRING_WEEK = 1
	SUMMER_WEEK = 5
	FALL_WEEK = 9
	WINTER_WEEK = 13
	FINAL_WEEK = 13
	END_TURN_DISCARD = true
	IRRIGATE_PROTECTED = false
	MAX_HAND_SIZE = 10
	LUNAR_FARM = false
	MAGE = ""
	BLOCK_RITUAL = false
	BLOCK_GROW = false
	click_callbacks = []
	Constants.BASE_HAND_SIZE = 5
	MAX_BLIGHT = 5
	ALL_WATERED = false
	WATERED_MULTIPLIER = 0.4
	MAX_HEALTH = 100
	ACORNS = 0
	ACORN_BONUS = 0.0

static func register_click_callback(obj):
	click_callbacks.append(obj)

static func notify_click_callback():
	for callback in click_callbacks:
		callback.on_other_clicked()
