extends Fortune
class_name MageAbility

var modify_deck_callback: Callable = func(_deck): pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func register_fortune(event_manager: EventManager):
	Global.MAGE = name