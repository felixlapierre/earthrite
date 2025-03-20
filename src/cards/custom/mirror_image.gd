extends CardData
class_name MirrorImage

var callback: Callable
var event_type = EventManager.EventType.OnActionCardUsed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var options: Array[Tile] = []
		var target_tile: Tile = args.specific.tile
		
		var mirror_location: Vector2 = Vector2(7 - target_tile.grid_location.x, target_tile.grid_location.y)
		
		if Helper.in_bounds(mirror_location):
			var mirror: Tile = args.farm.tiles[mirror_location.x][mirror_location.y]
			if [Enums.TileState.Growing, Enums.TileState.Mature].has(mirror.state):
				var temp = mirror.state
				mirror.state = Enums.TileState.Empty
				if mirror.card_can_target(target_tile.seed):
					mirror.destroy_plant()
				else:
					mirror.state = temp
			if mirror.card_can_target(target_tile.seed):
				mirror.set_seed(target_tile.seed.copy())
				mirror.current_grow_progress = target_tile.current_grow_progress
				mirror.current_yield = target_tile.current_yield
				mirror.state = target_tile.state
				mirror.update_plant_sprite()
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = MirrorImage.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return false
