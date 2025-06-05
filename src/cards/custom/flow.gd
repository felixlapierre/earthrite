extends CardData
class_name GrowWatered

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		do_watered(args, func(tile):
			args.farm.do_animation(load("res://src/animation/frames/flow_sf.tres"), tile.grid_location))
		await args.farm.get_tree().create_timer(delay).timeout
		do_watered(args, func(tile):
			await tile.grow_one_week())
					
	event_manager.register_listener(event_type, callback)

func do_watered(args: EventArgs, call: Callable):
	for tile in args.farm.get_all_tiles():
		if tile.is_watered() and tile.state == Enums.TileState.Growing:
			for i in range(strength):
				call.call(tile)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = GrowWatered.new()
	new.assign(self)
	return new

func get_description() -> String:
	var desc = super.get_description()
	return desc.replace("weeks", "week" if strength == 1 else "weeks")

func get_long_description():
	return Helper.get_long_description("watered") + super.get_long_description()

func can_strengthen_custom_effect():
	return true
