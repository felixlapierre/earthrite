extends Camera2D
class_name ShakeCamera2D

@export var defaultStrength: float = 30.0
@export var shakeFade: float = 5.0
var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func apply_shake(strength: float):
	shake_strength = strength

func _process(delta: float):
	if Input.is_action_just_pressed("transform"):
		apply_shake(100.0)
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		
		offset = randomOffset()

func randomOffset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength))
	
	
