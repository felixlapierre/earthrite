extends StrEffect
class_name AddManaAll

# To be overridden by specific code seeds
func register(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.seed != null and tile.get_effects("corrupted") != null:
				tile.add_yield(strength)
	event_manager.register_listener(timing, callback)

func unregister(event_manager: EventManager):
	event_manager.unregister_listener(timing, callback)

func copy():
	var new = AddManaAll.new();
	new.assign(self)
	return new

func get_description(size: int) -> String:
	return get_timing_text() + get_description_interp("Add {STRENGTH} " + Helper.mana_icon() + " to all plants")

func get_type():
	return "add_yield"
