extends CardData
class_name Mushroom

var tile: Tile
var callback: Callable

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	callback = func(args: EventArgs):
		var destroyed_tile: Tile = args.specific.tile
		if destroyed_tile.current_yield > 0:
			tile.add_yield(destroyed_tile.current_yield * self.strength)
	event_manager.register_listener(EventManager.EventType.OnPlantDestroyed, callback)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.OnPlantDestroyed, callback)

func copy():
	var new = Mushroom.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true

func get_long_description():
	return Helper.get_long_description("destroy_plant") + super.get_long_description()
