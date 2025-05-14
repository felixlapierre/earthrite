extends Node
class_name Mastery

static var MasteryLevel = 0

static var RitualTarget: int = 0
static var BlightAttack: int = 0
static var Misfortune: int = 0
static var HidePreview: int = 0
static var BlockShop: int = 0
static var CardRemoveCost: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static func save_data():
	var data = {}
	data.mastery_level = MasteryLevel
	data.RitualTarget = RitualTarget
	data.BlightAttack = BlightAttack
	data.Misfortune = Misfortune
	data.HidePreview = HidePreview
	data.BlockShop = BlockShop
	data.CardRemoveCost = CardRemoveCost
	return data

static func load_data(data):
	MasteryLevel = data.mastery_level if data.has("mastery_level") else 0
	RitualTarget = data.RitualTarget
	BlightAttack = data.BlightAttack
	Misfortune = data.Misfortune
	HidePreview = data.HidePreview
	BlockShop = data.BlockShop
	CardRemoveCost = data.CardRemoveCost

static func get_total_mastery():
	return MasteryLevel#RitualTarget + BlightAttack + Misfortune + HidePreview + BlockShop + CardRemoveCost

static func hide_preview():
	return MasteryLevel >= 2

static func less_options():
	return 1 if Global.DIFFICULTY >= 6 else 0

static func less_explore():
	return 1 if MasteryLevel >= 4 else 0

static func less_enhance():
	return 1 if MasteryLevel >= 5 else 0

static func reset():
	RitualTarget = 0
	BlightAttack = 0
	Misfortune = 0
	HidePreview = 0
	BlockShop = 0
	CardRemoveCost = 0
	MasteryLevel = 0

static func get_prompt_text():
	var level = MasteryLevel
	var prompt_text = "Ritual target & Blight strength "
	for i in range(level):
		prompt_text += "+"
	prompt_text += "\nBlight is more dangerous"
	prompt_text += "\nAttack preview will only show the next turn" if level >= 2 else ""
	prompt_text += "\nFewer options available when selecting rewards" if level >= 3 else ""
	prompt_text += "\n-1 explore point" if level >= 4 else ""
	prompt_text += "\nMax 1 enhance per card" if level >= 5 else ""
	return prompt_text
