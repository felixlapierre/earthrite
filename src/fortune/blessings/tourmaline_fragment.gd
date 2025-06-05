extends Fortune
class_name TourmalineFragment

var icon = preload("res://assets/card/chronoweave.png")
var callback
var event_type = EventManager.EventType.BeforeTurnStart

func _init() -> void:
	super("Tourmaline Fragment", Fortune.FortuneType.GoodFortune, "Grow one of your slowest plants at the start of each turn", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		var longest = 0
		var longest_tiles = []
		for tile in args.farm.get_all_tiles():
			if tile.seed != null and tile.state != Enums.TileState.Mature:
				if tile.seed.time > longest:
					longest = tile.seed.time
					longest_tiles = [tile]
				elif tile.seed.time == longest:
					longest_tiles.append(tile)
		longest_tiles.shuffle()
		if longest_tiles.size() > 0:
			await longest_tiles[0].grow_one_week()
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
