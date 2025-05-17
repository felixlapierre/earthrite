extends Node2D
class_name VisualsBlightRitual

@onready var blight_spike: AnimatedSprite2D = $BlightSpike
@onready var white_square: ColorRect = $WhiteSquare

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_blight_damage():
	blight_spike.play("default")

func flash():
	white_square.modulate = Color(Color.WHITE, 0.7)
	get_tree().create_tween().tween_property(white_square, "modulate", Color(Color.WHITE, 0.0), 2.0)
