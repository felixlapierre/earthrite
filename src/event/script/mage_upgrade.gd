extends CustomEvent

var arrow = load("res://assets/ui/arrow.png")

func _init():
	super._init("Mastery", "This description is blank for now, sorry!")
	#var option2 = CustomEvent.Option.new("Choose a new Mage Power", null,\
	#	func(): pass)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var nodes: Array[Node] = []
	var node1 = FortuneDisplay.instantiate()
	node1.setup(user_interface.mage_fortune)
	nodes.append(node1)
	
	nodes.append(display_rect(arrow))
	
	var copy = load(user_interface.mage_fortune.get_script().get_path()).new()
	copy.strength += copy.str_inc
	copy.update_text()
	var node2 = FortuneDisplay.instantiate()
	node2.setup(copy)
	nodes.append(node2)
	
	var option1 = CustomEvent.Option.new("Upgrade your Mage Power",\
		nodes_preview("Upgrade your Mage Power", nodes), func():
		user_interface.mage_fortune.upgrade_power()
		user_interface.create_fortune_display()
		user_interface.explore.show_window())
	
	return [option1]

func check_prerequisites():
	return turn_manager.year > 4 and user_interface.mage_fortune.name != "Pyromancer" and user_interface.mage_fortune.name != "Archmage"
