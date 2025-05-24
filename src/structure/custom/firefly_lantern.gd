extends Effect2
class_name FireflyLantern

var listener
var strength = 3

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.new(timing, func(args: EventArgs):
		var candidates = []
		for t in Helper.get_adjacent_active_tiles(tile.grid_location, args.farm):
			if t.seed != null:
				candidates.append(t)
		candidates.shuffle()
		for i in range(min(strength, candidates.size())):
			candidates[i].protected = true
			candidates[i].update_display()
			tile.play_effect_particles()
		)
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	return FireflyLantern.new().assign(self)

func get_description(size):
	return get_timing_text() + "[color=gold]Protect[/color] " + str(strength) + " random adjacent plant"

func get_type():
	return Enums.EffectType.Protect
