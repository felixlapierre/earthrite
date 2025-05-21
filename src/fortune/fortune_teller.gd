extends Node2D
class_name FortuneTeller

var event_manager: EventManager
var data_fetcher = preload("res://src/cards/cards_database.gd")
var fortune_display_scene = preload("res://src/fortune/fortune.tscn")
var attack_database: AttackDatabase

var fortune_map = {}
var size = 0

var current_fortunes: Array[Fortune] = []
var attack_pattern: AttackPattern

signal on_close

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CenterContainer.custom_minimum_size = Constants.VIEWPORT_SIZE
	attack_database = AttackDatabase.new()
	attack_database.populate_database()

func setup(p_event_manager: EventManager):
	event_manager = p_event_manager
	attack_pattern = AttackPattern.new()

func create_fortunes():
	# Clear last week's fortunes
	current_fortunes.clear()
	for child in $CenterContainer/PanelContainer/VBox/Fortunes.get_children():
		$CenterContainer/PanelContainer/VBox/Fortunes.remove_child(child)

	var misfortune = Global.DIFFICULTY >= Constants.DIFFICULTY_MISFORTUNE
	var year = event_manager.turn_manager.year
	
	var difficulty = "easy"
	match Global.DIFFICULTY:
		2, 3, 4:
			difficulty = "hard"
		5, 6:
			difficulty = "mastery"
		7:
			difficulty = "absurd"
	attack_pattern = Helper.pick_random(attack_database.get_attacks(difficulty, year))
	attack_database.remove_attack(attack_pattern, difficulty, year)
	
	#if Global.DIFFICULTY >= Constants.DIFFICULTY_HARD:
	#	attack_pattern = attacks_advanced.get_advanced_attack_year(year)
	#else:
	#	attack_pattern = simple_attacks.get_simple_attack_year(year, misfortune)
	
	#current_fortunes = attack_pattern.get_fortunes_at_week(0)
	## Ensure we get a random fortune
	#for type in Fortune.FortuneType.values():
		#fortune_map[type].shuffle()
#
	## Select the fortunes based on week
	#if Global.DIFFICULTY < Constants.DIFFICULTY_MISFORTUNE:
		#current_fortunes.append(get_fortune(Fortune.FortuneType.GoodFortune, 0))
		#get_current_fortunes_regular()
	#else:
		#get_current_fortunes_misfortune()

	# Display the fortunes
	display_fortunes()

func get_current_fortunes_regular():
	match event_manager.turn_manager.year + 1:
		2, 3:
			bad_fortune(0)
		4, 5:
			bad_fortune(1)
		6:
			bad_fortune(1)
			bad_fortune(0)
		7:
			bad_fortune(2)
		8:
			bad_fortune(2)
			bad_fortune(0)
		9:
			bad_fortune(2)
			bad_fortune(1)
		10:
			bad_fortune(3)
		_:
			bad_fortune(3)
			bad_fortune(2)
			bad_fortune(1)

func bad_fortune(rank: int):
	current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, rank))

func get_current_fortunes_misfortune():
	match event_manager.turn_manager.year + 1:
		2, 3:
			bad_fortune(0)
		4:
			bad_fortune(1)
		5:
			bad_fortune(1)
			bad_fortune(0)
		6:
			bad_fortune(1)
			bad_fortune(1)
		7:
			bad_fortune(2)
			bad_fortune(0)
		8:
			bad_fortune(2)
			bad_fortune(1)
		9:
			bad_fortune(2)
			bad_fortune(2)
		10:
			bad_fortune(3)
			bad_fortune(2)
			bad_fortune(2)
		_:
			bad_fortune(3)
			bad_fortune(2)
			bad_fortune(1)
			bad_fortune(0)

func add_bad_fortune(rank: int):
	current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, rank))

func get_fortune(type: Fortune.FortuneType, rank: int):
	var options = []
	for fortune in fortune_map[type]:
		if fortune.rank == rank and !current_fortunes.has(fortune) and !current_fortunes.any(func(current):
			return fortune.name.split(" ")[0] == current.name.split(" ")[0]):
			options.append(fortune)
	options.shuffle()
	return options[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_fortunes():
	for fortune in current_fortunes:
		fortune.register_fortune(event_manager)

func unregister_fortunes():
	for fortune in current_fortunes:
		fortune.unregister_fortune(event_manager)

func _on_click_out_button_pressed() -> void:
	on_close.emit()

func load_fortunes(fortunes):
	for data in fortunes:
		var fortune = load(data.path).new()
		fortune.load_data(data)
		current_fortunes.append(fortune)
	display_fortunes()

func display_fortunes():
	for fortune in attack_pattern.get_all_fortunes_display():
		var display: Control = fortune_display_scene.instantiate()
		display.find_child("Name").text = fortune.name
		display.find_child("Description").text = fortune.get_description()
		display.find_child("Texture").texture = fortune.texture
		$CenterContainer/PanelContainer/VBox/Fortunes.add_child(display)
