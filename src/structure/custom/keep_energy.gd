extends Structure
class_name KeepEnergy

var callback: Callable
var callback2: Callable
var callback3: Callable

var event_type = EventManager.EventType.OnTurnEnd
var event2 = EventManager.EventType.BeforeTurnStart
var event3 = EventManager.EventType.BeforeYearStart

var energy = 0
func _init():
	super()

func copy():
	var copy = KeepEnergy.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		energy = args.turn_manager.energy
		args.turn_manager.energy = 0
	
	callback2 = func(args: EventArgs):
		args.turn_manager.energy += energy
		if energy > 0:
			tile.play_effect_particles()

	callback3 = func(args: EventArgs):
		energy = 0
	event_manager.register_listener(event_type, callback)
	event_manager.register_listener(event2, callback2)
	event_manager.register_listener(event3, callback3)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
	event_manager.unregister_listener(event2, callback2)
	event_manager.unregister_listener(event3, callback3)
