extends Effect2
class_name Dandelion

var listener: Listener

func _init():
	super(EventManager.EventType.OnPlantGrow, true, Enums.EffectType.Harvest, "Dandelion")

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var t = args.specific.tile
		if t.state == Enums.TileState.Mature:
			await p_tile.harvest(false)
		)
	
	owner.register(listener)

func unregister_seed_events(event_manager: EventManager):
	listener.disable()

func copy():
	var new = Dandelion.new();
	new.assign(self)
	return new

func get_description(size):
	return "Harvests itself when fully grown"
