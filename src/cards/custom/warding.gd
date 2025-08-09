extends CardData
class_name Warding

var callback: Callable
var event_type = EventManager.EventType.OnPlantHarvest

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	super.register_events(event_manager, p_tile)
	callback = func(args: EventArgs):
		args.specific.harvest_args.purple = !args.specific.harvest_args.purple
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = Warding.new()
	new.assign(self)
	return new
