extends Effect2
class_name IngrainEffect

var listener: Listener

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.Regrow, "IngrainEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var regrow_effect = load("res://src/effect2/basic/regrow_0.tres")
		var seed = args.specific.tile.seed
		regrow_effect.owner = seed
		seed.effects2.append(regrow_effect)
		regrow_effect.register(event_manager, args.specific.tile)
		seed.enhances.append({
			"name": "regrow",
			"type": Enhance.Type.Regrow
		})
		args.specific.tile.play_effect_particles()
	)
	owner.register(listener)

func unregister(e):
	listener.disable()

func get_description(size):
	return "Add [color=gold]Regrow[/color] to target plants"

func copy():
	return IngrainEffect.new().assign(self)
