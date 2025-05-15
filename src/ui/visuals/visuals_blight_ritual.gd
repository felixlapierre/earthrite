extends Node2D
class_name VisualsBlightRitual

@onready var blight_spike: AnimatedSprite2D = $BlightSpike

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_blight_damage():
	blight_spike.play("default")
