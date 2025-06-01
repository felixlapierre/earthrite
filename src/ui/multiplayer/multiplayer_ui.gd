extends Node2D
class_name MultiplayerUi

@onready var WaitingContainer = $Waiting

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_waiting_visible(is_visible: bool):
	WaitingContainer.visible = is_visible
