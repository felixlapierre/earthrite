extends Effect2
class_name ProtectTile

var callback_turn_start: Callable
var callback_year_start: Callable

var my_tile: Tile

func register(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		my_tile = args.specific.tile
		args.specific.tile.protected = true
	callback_turn_start = func(args: EventArgs):
		my_tile.protected = true
	callback_year_start = func(args: EventArgs):
		event_manager.unregister_listener(EventManager.EventType.BeforeTurnStart, callback_turn_start)
		event_manager.unregister_listener(EventManager.EventType.BeforeYearStart, callback_year_start)
	event_manager.register_listener(timing, callback)
	event_manager.register_listener(EventManager.EventType.BeforeTurnStart, callback_turn_start)
	event_manager.register_listener(EventManager.EventType.BeforeYearStart, callback_year_start)
	
func unregister(event_manager: EventManager):
	event_manager.unregister_listener(timing, callback)

func copy():
	var copy = ProtectTile.new()
	copy.assign(self)
	return copy

func get_description(size: int):
	return "Protect " + str(size) + " tile(s)"

func get_long_description():
	return Helper.get_long_description("protect")
