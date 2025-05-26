extends Node
class_name Unlocks

static var TUTORIAL_COMPLETE = false

static var FARMS_UNLOCKED: Dictionary = {}
static var DIFFICULTIES_UNLOCKED: Dictionary = {}
static var MAGES_UNLOCKED: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
static func save_unlocks():
	var unlocks_json = {
		"tutorial_complete": TUTORIAL_COMPLETE,
		"farms": FARMS_UNLOCKED,
		"difficulties": DIFFICULTIES_UNLOCKED,
		"mages": MAGES_UNLOCKED
	}
	var unlocks = FileAccess.open("user://unlocks.save", FileAccess.WRITE)
	unlocks.store_line(JSON.stringify(unlocks_json))

static func load_unlocks():
	if not FileAccess.file_exists("user://unlocks.save"):
		default_unlocks()
		return
	var unlocks_fileread = FileAccess.open("user://unlocks.save", FileAccess.READ)
	var unlocks_data = unlocks_fileread.get_line()
	var json = JSON.new()
	var parse_result = json.parse(unlocks_data)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	var unlocks_json = json.get_data()
	TUTORIAL_COMPLETE = unlocks_json.tutorial_complete
	FARMS_UNLOCKED = unlocks_json.farms
	DIFFICULTIES_UNLOCKED = unlocks_json.difficulties
	MAGES_UNLOCKED = unlocks_json.mages
	for i in range(8):
		if !DIFFICULTIES_UNLOCKED.has(str(i)):
			DIFFICULTIES_UNLOCKED[str(i)] = false
	for i in range(8):
		if !FARMS_UNLOCKED.has(str(i)):
			FARMS_UNLOCKED[str(i)] = false
	fill(MAGES_UNLOCKED, 11)

static func fill(dict: Dictionary, amt):
	for i in range(amt):
		if !dict.has(str(i)):
			dict[str(i)] = false

static func default_unlocks():
	TUTORIAL_COMPLETE = false
	FARMS_UNLOCKED = {
		"0": true,
		"1": true,
		"2": true,
		"3": true,
		"4": false,
		"5": false,
		"6": false,
		"7": true
	}
	DIFFICULTIES_UNLOCKED = {
		"0": true,
		"1": true,
		"2": false,
		"3": false,
		"4": false,
		"5": false,
		"6": false,
		"7": false
	}
	MAGES_UNLOCKED = {
		"0": true,
		"1": true,
		"2": true,
		"3": true,
		"4": false,
		"5": false,
		"6": false,
		"7": false,
		"8": false,
		"9": false,
		"10": false
	}
