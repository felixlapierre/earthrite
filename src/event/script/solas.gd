extends CustomEvent

var spring_blessing = preload("res://src/fortune/unique/spring_blessing.gd").new()
var summer_blessing = preload("res://src/fortune/unique/summer_blessing.gd").new()
var fall_blessing = preload("res://src/fortune/unique/fall_blessing.gd").new()

var solas_curse = preload("res://src/fortune/curses/solar_curse.gd").new()

func _init():
	super._init("God of Seasons", "This description is blank for now, sorry!")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var nodes: Array[Node] = []
	var node1 = FortuneDisplay.instantiate()
	node1.setup(spring_blessing)
	var node2 = FortuneDisplay.instantiate()
	node2.setup(summer_blessing)
	var node3 = FortuneDisplay.instantiate()
	node3.setup(fall_blessing)
	var node4 = FortuneDisplay.instantiate()
	node4.setup(solas_curse)

	var option1 = CustomEvent.Option.new("Accept one of the Blessings of Solas",\
	nodes_preview("Pick one of the 3 Blessings", [node1, node2, node3]), func():
		user_interface.pick_blessing("Pick a blessing to gain", [spring_blessing, summer_blessing, fall_blessing])
	)
	var option2 = CustomEvent.Option.new("Steal all of the blessings", nodes_preview("Gain all 3 Blessings, and the Curse of Solas", [node1, node2, node3, node4]), func():
		for fortune in [spring_blessing, summer_blessing, fall_blessing, solas_curse]:
			user_interface._on_explore_on_fortune(fortune)
		user_interface.explore.show_window()
	)
	return [option1, option2]

func check_prerequisites():
	return true
