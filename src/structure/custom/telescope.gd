extends Structure
class_name Telescope

var callback: Callable

var event_type = EventManager.EventType.AfterYearStart

func _init():
	super()

func copy():
	var copy = Telescope.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	Explore.bonus_explores += 1
	callback = func(args: EventArgs):
		Explore.bonus_explores += 1
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
