extends CardData
class_name Bloodrite

var callback: Callable
var event_type = EventManager.EventType.OnActionCardUsed
var callback2: Callable
var event_type2 = EventManager.EventType.BeforeCardPlayed

var blighroot_seed = load("res://src/fortune/unique/blightroot.tres")

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		args.specific.tile.add_yield(self.strength * args.turn_manager.get_blight_strength())

	callback2 = func(args: EventArgs):
		var eligible_blightroot: Array[Tile] = []
		for tile: Tile in args.farm.get_all_tiles():
			if tile.state == Enums.TileState.Empty and !tile.is_protected() and !tile.is_destroyed():
				eligible_blightroot.append(tile)
		eligible_blightroot.shuffle()
		var i = 0
		while i < eligible_blightroot.size() and i < 1:#args.turn_manager.blight_damage:
			eligible_blightroot[i].plant_seed_animate(blighroot_seed)
			i += 1
		
	event_manager.register_listener(event_type, callback)
	#event_manager.register_listener(event_type2, callback2)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
	#event_manager.unregister_listener(event_type2, callback2)

func copy():
	var new = Bloodrite.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true

func preview_yield(tile: Tile):
	var args = EventArgs.HarvestArgs.new(0, tile.purple, false)
	args.green = strength
	return args
