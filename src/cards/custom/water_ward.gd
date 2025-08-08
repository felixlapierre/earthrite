extends CardData
class_name WaterWard

var callback: Callable
var event_type = EventManager.EventType.AfterCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	super.register_events(event_manager, p_tile)
	callback = func(args: EventArgs):
		await args.farm.get_tree().create_timer(delay).timeout
		for tile in args.farm.get_all_tiles():
			if tile.is_watered() and tile.state != Enums.TileState.Inactive:
				var harvest_args = EventArgs.HarvestArgs.new(self.strength, true, false)
				args.farm.gain_yield(tile, harvest_args)
				args.farm.do_animation(load("res://src/animation/frames/water_ward_sf.tres"), tile.grid_location)
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = WaterWard.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true

func preview_yield(tile: Tile):
	var purple = 0
	if tile.is_watered() and tile.state != Enums.TileState.Inactive:
		purple = self.strength
	return EventArgs.HarvestArgs.new(purple, true, false)
