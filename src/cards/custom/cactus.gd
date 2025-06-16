extends Effect2
class_name Cactus

var tile: Tile

var listener_other_plant_played: Listener
var listener_cactus_played: Listener

func _init():
	super(EventManager.EventType.OnPlantPlanted, true, Enums.EffectType.DestroyPlant, "Cactus")

# To be overridden by specific code seeds
func register(event_manager: EventManager, p_tile: Tile):
	tile = p_tile

	listener_other_plant_played = Listener.create(self, func(args: EventArgs):
		var planted_tile = args.specific.tile
		if planted_tile != tile and Helper.is_adjacent(planted_tile.grid_location, tile.grid_location):
			planted_tile.destroy_plant())

	listener_cactus_played = Listener.create(self, func(args: EventArgs):
		var shape = Helper.get_tile_shape(8, Enums.CursorShape.Elbow)
		for entry in shape:
			var target = tile.grid_location + entry
			if Helper.in_bounds(target):
				var target_tile: Tile = args.farm.tiles[tile.grid_location.x + entry.x][tile.grid_location.y + entry.y]
				if (target_tile.state == Enums.TileState.Growing or target_tile.state == Enums.TileState.Mature):
					target_tile.destroy_plant())

	event_manager.register(listener_other_plant_played)
	owner.register(listener_cactus_played)

func unregister(event_manager: EventManager):
	listener_other_plant_played.disable()
	listener_cactus_played.disable()

func copy():
	var new = Cactus.new();
	new.assign(self)
	return new

func get_description(size):
	return "Destroy adjacent plants"
