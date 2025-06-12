extends Node
class_name Settings

static var DEBUG: bool = false
static var TUTORIALS_ENABLED: bool = true
static var CLICK_MODE: bool = false
static var TUTORIALS_V2: bool = true
static var DISPLAY_NAME: String = "Mage"
static var JOIN_IP_ADDRESS: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func save_settings():
	var settings_json = {
		"debug": DEBUG,
		"tutorials": TUTORIALS_ENABLED,
		"click_mode": CLICK_MODE,
		"tutorials_v2": TUTORIALS_V2,
		"display_name": DISPLAY_NAME,
		"JOIN_IP_ADDRESS": JOIN_IP_ADDRESS
	}
	var settings = FileAccess.open("user://settings.save", FileAccess.WRITE)
	settings.store_line(JSON.stringify(settings_json))

static func load_settings():
	if not FileAccess.file_exists("user://settings.save"):
		return null
	var settings_fileread = FileAccess.open("user://settings.save", FileAccess.READ)
	var settings_data = settings_fileread.get_line()
	var json = JSON.new()
	var parse_result = json.parse(settings_data)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	var settings_json = json.get_data()
	DEBUG = settings_json.debug
	TUTORIALS_ENABLED = settings_json.tutorials
	CLICK_MODE = (settings_json.has("click_mode") and settings_json.click_mode) or false
	TUTORIALS_V2 = (settings_json.has("tutorials_v2") and settings_json.tutorials_v2) or false
	DISPLAY_NAME = (settings_json.display_name if settings_json.has("display_name") else "Mage")
	JOIN_IP_ADDRESS = (settings_json.JOIN_IP_ADDRESS if settings_json.has("JOIN_IP_ADDRESS") else "")
