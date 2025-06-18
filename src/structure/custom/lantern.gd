extends Structure
class_name Lantern

var callback_cardplay
var turnstart_listener: Listener

var event_type_cardplay = EventManager.EventType.BeforeCardPlayed

var count = 0

func _init():
	super()

func copy():
	var copy = Lantern.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback_cardplay = func(args: EventArgs):
		count += 1
		if count >= 5:
			count -= 5
			var tiles: Array[Tile] = args.farm.get_all_tiles().filter(func(tile): return tile.seed != null)
			tiles.shuffle()
			for i in range(min(tiles.size(), 24)):
				tiles[i].add_yield(1)
	
	turnstart_listener = Listener.new(EventManager.EventType.BeforeTurnStart, func(args: EventArgs):
		count = 0)

	event_manager.register(turnstart_listener)
	event_manager.register_listener(event_type_cardplay, callback_cardplay)

func unregister_events(event_manager: EventManager):
	turnstart_listener.disable()
	event_manager.unregister_listener(event_type_cardplay, callback_cardplay)
