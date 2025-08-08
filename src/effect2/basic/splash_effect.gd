extends StrEffect
class_name SplashEffect

var listener: Listener

func _init():
	super(EventManager.EventType.AfterCardPlayed, false, Enums.EffectType.Water, "SplashEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var candidates = args.farm.get_all_tiles()\
			.filter(func(t: Tile): return !t.is_watered() and t.state != Enums.TileState.Inactive)
		#candidates.sort_custom(func(a: Tile, b: Tile):
		#	var x = args.specific.tile.grid_location.x
		#	var y = args.specific.tile.grid_location.y
		#	var adist = abs(a.grid_location.y - y) + abs(a.grid_location.x - x)
		#	var bdist = abs(b.grid_location.y - y) + abs(b.grid_location.x - x)
		#	return adist < bdist)
		candidates.shuffle()
		for i in range(strength):
			if candidates.size() > 0:
				var t = candidates.pop_front()
				t.irrigate()
				t.update_display()
	)
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return get_timing_text() + "[color=gold]Splash[/color] " + highlight(str(strength))

func copy():
	return SplashEffect.new().assign(self)
