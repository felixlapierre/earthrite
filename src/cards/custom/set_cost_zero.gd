extends Effect2
class_name SetCostZero
	
var listener: Listener

func _init():
	super(EventManager.EventType.OnPlantHarvest, true, Enums.EffectType.Other, "SetCostZero")

# To be overridden by specific code seeds
func register(event_manager: EventManager, p_tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.cards.make_random_card_free()
		args.specific.tile.play_effect_particles()
	)

	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size):
	return get_timing_text() + "Set the {ENERGY} Cost of a random card in your hand to 0"

func copy():
	var new = SetCostZero.new()
	new.assign(self)
	return new
