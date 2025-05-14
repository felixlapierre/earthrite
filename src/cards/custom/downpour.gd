extends CardData
class_name Downpour

var callback: Callable
var event_type = EventManager.EventType.OnActionCardUsed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var inc = 0
		for tile in args.farm.get_all_tiles():
			if tile.is_watered():
				inc += strength
		args.specific.tile.add_yield(inc)
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = Downpour.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true

func preview_yield(tile: Tile):
	var args = EventArgs.HarvestArgs.new(0, tile.purple, false)
	var farm: Farm = tile.get_parent().get_parent()
	var inc = 0
	for farm_tile in farm.get_all_tiles():
		if farm_tile.is_watered():
			inc += strength
	args.green = inc
	return args

func get_long_description():
	return Helper.get_long_description("watered") + super.get_long_description()
