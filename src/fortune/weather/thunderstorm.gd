extends Fortune
class_name ThunderstormWeather

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart

var display_texture = preload("res://assets/mage/Storm.png")
var lightning_sf = preload("res://src/animation/other/lightning_sf.tres")
func _init() -> void:
	super("Thunderstorm", Fortune.FortuneType.GoodFortune, "Turn start: Destroy 1 plant and gain 1 energy. Repeat for every 10 plants on your farm.", 0, display_texture, strength)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		var options: Array[Tile] = []
		for tile in args.farm.get_all_tiles():
			if [Enums.TileState.Mature, Enums.TileState.Growing].has(tile.state) and !tile.is_protected():
				options.append(tile)
		options.shuffle()
		if options.size() == 0:
			return
		for i in range((options.size() / 10) + 1):
			options[i].destroy_plant()
			args.farm.do_animation(lightning_sf, options[i].grid_location)
			args.turn_manager.energy += 1
		args.user_interface.update()
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
