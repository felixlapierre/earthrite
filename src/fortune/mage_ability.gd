extends Fortune
class_name MageAbility

var modify_deck_callback: Callable = func(_deck): pass
var str_inc = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func register_fortune(event_manager: EventManager):
	Global.MAGE = name

func upgrade_power():
	pass

func update_text():
	pass

func do_setup_dialogue(node: Node):
	pass
