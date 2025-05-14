extends CardData
class_name RainbowCactus

var tile: Tile
var callback: Callable

var event_type = EventManager.EventType.AfterCardPlayed

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	callback = func(args: EventArgs):
		var shape = Helper.get_tile_shape(8, Enums.CursorShape.Elbow)
		for entry in shape:
			var target_tile: Tile = args.farm.tiles[tile.grid_location.x + entry.x][tile.grid_location.y + entry.y]
			if (target_tile.state == Enums.TileState.Growing or target_tile.state == Enums.TileState.Mature):
				target_tile.destroy_plant()
				tile.add_yield(strength)
	event_manager.register_listener(event_type, callback)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = RainbowCactus.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true

func get_long_description():
	return Helper.get_long_description("destroy_plant") + "\n" + super.get_long_description()
