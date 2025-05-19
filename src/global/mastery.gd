extends Node
class_name Mastery

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static func less_options():
	return 1 if Global.DIFFICULTY >= 6 else 0

static func less_enhance():
	return 0

static func hide_preview():
	return false
