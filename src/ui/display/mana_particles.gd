extends Node2D
class_name ManaParticles

@onready var particles: GPUParticles2D = $ManaParticles

# How to use:
# - Set position
# - Optionally set color, size, amount

@export var color: Color = Color8(255, 252, 64)
@export var size: float = 100.0
@export var amount: int = 10
@export var on_finish: Callable
@export var max_scale = 3
@export var hue_variation_max: float = 0.0
@export var acceleration = Vector2(0, 0)

var t = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	particles.modulate = color
	particles.process_material.emission_sphere_radius = size
	particles.one_shot = true
	particles.amount = amount
	particles.process_material.scale_max = max_scale
	particles.process_material.hue_variation_max = hue_variation_max
	particles.process_material.gravity = Vector3(acceleration.x, acceleration.y, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	if t > particles.lifetime and on_finish:
		on_finish.call()
	
