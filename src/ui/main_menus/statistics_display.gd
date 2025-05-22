extends Control
class_name StatisticsDisplay

@onready var full_stats_cont: GridContainer = $FullStatsCont
@onready var farm_stats_cont: GridContainer = $HBox/FarmMargin/FarmVBox/FarmWinsCont
@onready var mage_wins_cont: GridContainer = $HBox/MageMargin/MageVBox/MageWinsCont

@onready var best_wins_cont = $HBox

signal back

var score = 0

static var icons = {
	"Easy": preload("res://assets/ui/Easy.png"),
	"Normal":  preload("res://assets/ui/Normal.png"),
	"Hard": preload("res://assets/ui/Hard.png"),
	"Mastery1": preload("res://assets/ui/Mastery1.png"),
	"Mastery2": preload("res://assets/ui/Mastery2.png"),
	"Mastery3": preload("res://assets/ui/Mastery3.png"),
	"Mastery4": preload("res://assets/ui/Mastery4.png"),
	"Mastery5": preload("res://assets/ui/Mastery5.png")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_stats_display(mage_fortune_list: Array[MageAbility]):
	Statistics.load_stats()
	score = 0
	var farms: Array[String] = ["FOREST", "MOUNTAINS", "WILDERNESS", "RIVERLANDS", "LUNARTEMPLE", "STORMVALE", "SCRAPYARD"]
	var farm_icons = [load("res://assets/mage/forest.png"), load("res://assets/fortune/mountains.png"), load("res://assets/fortune/wildflowers-fortune.png"), load("res://assets/mage/riverlands.png"), load("res://assets/card/temporal_rift.png"), load("res://assets/mage/Storm.png"), load("res://assets/custom/Temp.png")]
	
	for child in farm_stats_cont.get_children():
		farm_stats_cont.remove_child(child)
	for child in mage_wins_cont.get_children():
		mage_wins_cont.remove_child(child)
	for child in full_stats_cont.get_children():
		full_stats_cont.remove_child(child)

	# Farm stats display
	for i in range(farms.size()):
		var name = farms[i].to_lower().capitalize()
		add_rect(farm_stats_cont, farm_icons[i])
		var label = Label.new()
		label.text = name + ": "
		farm_stats_cont.add_child(label)
		farm_stats_cont.add_child(VSeparator.new())
		var diff = Statistics.get_best_win_farm(farms[i])
		add_score(diff)
		var diff_icon = get_difficulty_icon(diff)
		var label2 = Label.new()
		label2.text = diff if diff != null else "None"
		add_rect(farm_stats_cont, diff_icon)
		farm_stats_cont.add_child(label2)
	
	# Mage stats display
	for mage: MageAbility in mage_fortune_list:
		add_rect(mage_wins_cont, mage.icon)
		var label = Label.new()
		label.text = mage.name + ": "
		mage_wins_cont.add_child(label)
		mage_wins_cont.add_child(VSeparator.new())
		var diff = Statistics.get_best_win_mage(mage.name)
		add_score(diff)
		var diff_icon = get_difficulty_icon(diff)
		var label2 = Label.new()
		label2.text = diff if diff != null else "None"
		add_rect(mage_wins_cont, diff_icon)
		mage_wins_cont.add_child(label2)

	# Full stats display
	add_rect(full_stats_cont, null)
	for icon in farm_icons:
		add_rect(full_stats_cont, icon)
	
	for mage: MageAbility in mage_fortune_list:
		add_rect(full_stats_cont, mage.icon)
		
		for farm in farms:
			var best = Statistics.get_best_win(mage.name, farm)
			add_rect(full_stats_cont, get_difficulty_icon(best))
	
	$ScoreLabel.text = "Score: "+ str(score)

static func get_difficulty_icon(diff):
	if diff == null:
		return null
	return icons[diff]

func add_rect(cont: GridContainer, texture: Texture2D):
	var rect = TextureRect.new()
	rect.custom_minimum_size = Vector2(32, 32)
	rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.texture = texture
	cont.add_child(rect)

static func get_farm_icon(farm):
	match farm:
		"FOREST":
			return load("res://assets/mage/forest.png")
		"MOUNTAINS":
			return load("res://assets/fortune/mountains.png")
		"WILDERNESS":
			return load("res://assets/fortune/wildflowers-fortune.png")
		"RIVERLANDS":
			return load("res://assets/mage/riverlands.png")
		"LUNARTEMPLE":
			return load("res://assets/card/temporal_rift.png")
		"STORMLANDS":
			return load("res://assets/mage/Storm.png")
		"SCRAPYARD":
			return load("res://assets/custom/Temp.png")


func _on_button_pressed():
	back.emit()

func _on_option_button_item_selected(index):
	best_wins_cont.visible = false
	full_stats_cont.visible = false
	match index:
		0:
			best_wins_cont.visible = true
		1:
			full_stats_cont.visible = true

func add_score(win):
	match win:
		null:
			score += 0
		"Easy":
			score += 1
		"Normal":
			score += 2
		"Hard":
			score += 3
		"Mastery1":
			score += 4
		"Mastery2":
			score += 5
		"Mastery3":
			score += 6
		"Mastery4":
			score += 7
		"Mastery5":
			score += 8
