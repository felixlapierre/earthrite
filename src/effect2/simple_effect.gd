extends Effect2
class_name SimpleEffect

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value
@export var eff_type: Enums.EffectType:
	set(value): effect_type = value
	
func _init():
	super(timing, seed, eff_type, "SimpleEffect")

func get_description(size):
	return "[color=gold]" + Enums.EffectType.keys()[effect_type] + "[/color]"

func copy():
	return SimpleEffect.new().assign(self)
