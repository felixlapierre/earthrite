extends Node2D
class_name VisualsBlightRitual

@onready var blight_spike: AnimatedSprite2D = $BlightSpike
@onready var white_square: ColorRect = $WhiteSquare
@onready var explosion: AnimatedSprite2D = $Explosion
var obelisk: TextureProgressBar
var turn_manager: TurnManager

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(p_obelisk: TextureProgressBar, p_turn_manager: TurnManager):
	obelisk = p_obelisk
	turn_manager = p_turn_manager
	var damage_inc = min(ceil(turn_manager.blight_damage / 20.0), 5)
	# TODO Fix obelisk atlas texture
	#var texture: AtlasTexture = obelisk.texture_under
	#texture.set_region(Rect2(min(32 * damage_inc, 32 * 6), 0, 32, 92))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_blight_damage():
	blight_spike.play("default")
	var damage_inc = min(ceil(turn_manager.blight_damage / 20.0), 5)
	# TODO Fix obelisk atlas texture
	#var texture: AtlasTexture = obelisk.texture_under
	#texture.set_region(Rect2(min(32 * damage_inc, 32 * 6), 0, 32, 92))

func death_boom():
	explosion.play("default")
	obelisk.texture_under.set_region(Rect2(32 * 6, 0, 32, 92))

func flash():
	white_square.modulate = Color(Color.WHITE, 0.7)
	get_tree().create_tween().tween_property(white_square, "modulate", Color(Color.WHITE, 0.0), 2.0)
