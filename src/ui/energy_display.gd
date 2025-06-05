extends Node2D

var mod_white = Color8(255, 255, 255)
var mod_black = Color8(0, 0, 0)
var mod_red = Color8(255, 0, 0)

var flashing = false
var energy = 3
var current_mod = mod_white

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_energy(p_energy: int):
	energy = p_energy
	var color = "black"
	if energy == 0:
		$Sprite2D.modulate = mod_black
		color = "red"
	else:
		$Sprite2D.modulate = mod_white
	set_text(str(energy), color)

func no_energy():
	flashing = true
	for i in range(5):
		await get_tree().create_timer(0.05).timeout
		set_text(str(energy), "white")
		$Sprite2D.modulate = mod_red
		await get_tree().create_timer(0.05).timeout
		set_text(str(energy), "red")
		$Sprite2D.modulate = mod_black
	set_energy(energy)
	await get_tree().create_timer(1.0).timeout
	flashing = false

func set_text(text: String, color: String):
	$Label.text = "[center][color=%s]%s[/color][/center]" % [color, text]
