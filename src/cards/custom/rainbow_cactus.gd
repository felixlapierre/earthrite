extends CardData
class_name RainbowCactus

var tile: Tile

var listener_cactus_played: Listener
var listener_other_plant_played: Listener

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	var current_tile_id = "null" if tile == null else tile.get_id()
	print("Instance " + str(get_instance_id()) + " tile " + current_tile_id + " = " + p_tile.get_id())
	tile = p_tile
	
	listener_other_plant_played = Listener.new("rainbow-cactus-" + tile.get_id(), EventManager.EventType.OnPlantPlanted, func(args: EventArgs):
		var planted_tile = args.specific.tile
		if planted_tile != tile and Helper.is_adjacent(planted_tile.grid_location, tile.grid_location):
			planted_tile.destroy_plant())
	
	listener_cactus_played = Listener.new("rainbow-cactus-self-" + tile.get_id(), EventManager.EventType.OnPlantPlanted, func(args: EventArgs):
		var shape = Helper.get_tile_shape(8, Enums.CursorShape.Elbow)
		for entry in shape:
			var target_tile: Tile = args.farm.tiles[tile.grid_location.x + entry.x][tile.grid_location.y + entry.y]
			if Helper.in_bounds(target_tile.grid_location):
				if (target_tile.state == Enums.TileState.Growing or target_tile.state == Enums.TileState.Mature):
					target_tile.destroy_plant()
					tile.add_yield(strength))

	event_manager.register(listener_other_plant_played)
	register(listener_cactus_played)

func unregister_seed_events(event_manager: EventManager):
	listener_cactus_played.disable()
	listener_other_plant_played.disable()

func copy():
	var new = RainbowCactus.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true

func get_long_description():
	return Helper.get_long_description("destroy_plant") + "\n" + super.get_long_description()
