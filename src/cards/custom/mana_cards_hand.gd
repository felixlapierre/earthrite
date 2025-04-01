extends CardData
class_name Onion

var tile: Tile
var callback: Callable

var event_type = EventManager.EventType.OnCardDrawn

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	callback = func(args: EventArgs):
		tile.add_yield(strength)
	event_manager.register_listener(event_type, callback)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = Onion.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
