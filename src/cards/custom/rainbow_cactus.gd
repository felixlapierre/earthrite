extends StrEffect
class_name RainbowCactus

var tile: Tile

var listener_cactus_played: Listener
var listener_other_plant_played: Listener

func _init():
	super(EventManager.EventType.OnPlantPlanted, true, Enums.EffectType.DestroyPlant, "RainbowCactus")

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	
	listener_other_plant_played = Listener.new(EventManager.EventType.OnPlantPlanted, func(args: EventArgs):
		var planted_tile = args.specific.tile
		if planted_tile != tile and Helper.is_adjacent(planted_tile.grid_location, tile.grid_location):
			planted_tile.destroy_plant()
			tile.add_yield(strength))
	
	listener_cactus_played = Listener.create(self, func(args: EventArgs):
		var shape = Helper.get_tile_shape(8, Enums.CursorShape.Elbow)
		for entry in shape:
			var target_tile: Tile = args.farm.tiles[tile.grid_location.x + entry.x][tile.grid_location.y + entry.y]
			if Helper.in_bounds(target_tile.grid_location):
				if (target_tile.state == Enums.TileState.Growing or target_tile.state == Enums.TileState.Mature):
					target_tile.destroy_plant()
					tile.add_yield(strength))

	event_manager.register(listener_other_plant_played)
	owner.register(listener_cactus_played)

func unregister_seed_events(event_manager: EventManager):
	listener_cactus_played.disable()
	listener_other_plant_played.disable()

func copy():
	var new = RainbowCactus.new();
	new.assign(self)
	return new

func get_description(size):
	return "Destroy adjacent plants and gain " + highlight(str(strength)) + Helper.mana_icon() + " per plant destroyed"
