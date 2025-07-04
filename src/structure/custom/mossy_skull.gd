extends Effect2
class_name MossySkull

var listener: Listener
var effects = []

func _init():
	super(EventManager.EventType.OnPlantDestroyed, false, Enums.EffectType.Regrow, "MossySkull")

func register(event_manager: EventManager, p_tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var tile = args.specific.tile
		var seed = tile.seed
		if seed != null and seed.yld > 0 and !seed.has_effect(Enums.EffectType.Corrupted):
			var effect = Effect.new("plant", 0.0, "", "", tile.grid_location, seed)
			effects.append(effect)
		)
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	var copy = MossySkull.new()
	copy.assign(self)
	return copy
