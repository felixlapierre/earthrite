extends CardData
class_name RegrowRandom

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

var regrow = preload("res://src/effect2/basic/regrow_0.tres")

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var eligible: Array[Tile] = []
		for tile: Tile in args.farm.get_all_tiles():
			if tile.seed != null and !tile.seed.has_effect(Enums.EffectType.Regrow):
				eligible.append(tile)
		eligible.shuffle()
		var i = 0
		while i < eligible.size() and i < strength:
			eligible[i].seed.effects.append(regrow)
			eligible[i].play_effect_particles()
			i += 1
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = RegrowRandom.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
