extends Node

class_name Listener

var id: String
var type: EventManager.EventType
var callback: Callable
var disabled: bool
var effect_type: Enums.EffectType
var order: int = 0

func _init(p_type = EventManager.EventType.BeforeTurnStart, p_callback = null, p_effect_type = Enums.EffectType.Other):
	id = str(randi())
	type = p_type
	callback = p_callback
	disabled = false
	effect_type = p_effect_type

static func create(owner: Resource, p_callback: Callable):
	var new_name = ""
	var n_effect_type = Enums.EffectType.Other
	var n_event_type = EventManager.EventType.BeforeTurnStart
	if "name" in owner:
		new_name += owner.name
	if "tile" in owner and owner.tile != null:
		new_name += "[%s-%s]" % [owner.tile.grid_location.x, owner.tile.grid_location.y]
	if "effect_type" in owner:
		n_effect_type = owner.effect_type
	if owner.has_method("get_type"):
		n_effect_type = owner.get_type()
	if "event_type" in owner:
		n_event_type = owner.event_type
	var l = Listener.new(n_event_type, p_callback, n_effect_type)
	l.id = new_name
	return l

func invoke(args: EventArgs):
	if !disabled:
		await callback.call(args)

func disable():
	disabled = true

func get_ordering():
	return get_effect_order() + order * 100

func get_effect_order():
	match effect_type:
		Enums.EffectType.GainMana: return 0
		Enums.EffectType.Protect: return 1
		Enums.EffectType.Water: return 2

		# Burn before Draw
		Enums.EffectType.Burn: return 10
		Enums.EffectType.Draw: return 11
		# Protect pretty early
		# Destroy, then Plant, then Add Mana, Grow, then Harvest,

		Enums.EffectType.DestroyPlant: return 20
		Enums.EffectType.DestroyTile: return 21
		Enums.EffectType.Plant: return 22
		Enums.EffectType.Spread: return 23
		Enums.EffectType.AddMana: 24
		Enums.EffectType.Grow: return 25
		Enums.EffectType.Harvest: return 26

		Enums.EffectType.Other: return 99
