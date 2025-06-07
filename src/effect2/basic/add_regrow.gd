extends Effect2
class_name AddRegrowEffect

var listener: Listener

var regrow_0_effect: RegrowEffect = preload("res://src/effect2/basic/regrow_0.tres")

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.Other, "AddRegrowEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var effect_copy: Effect2 = regrow_0_effect.copy()
		var seed = args.specific.tile.seed
		effect_copy.owner = seed
		seed.effects2.append(effect_copy)
		effect_copy.register(event_manager, tile)
	)
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return "Add [color=gold]Regrow[/color] to target plants"

func get_type():
	return Enums.EffectType.Other

func copy():
	return AddRegrowEffect.new().assign(self)
