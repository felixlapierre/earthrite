extends CardData
class_name Catalyze

var callback_after_play: Callable
var event_type_after_play = EventManager.EventType.AfterCardPlayed

func copy():
	var new = Catalyze.new()
	new.assign(self)
	return new

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback_after_play = func(args: EventArgs):
		var destroyed: int = 0
		for tile: Tile in args.farm.get_all_tiles():
			if tile.is_destroyed():
				destroyed += 1
		args.farm.on_energy_gained.emit((destroyed / 3) + strength)
	event_manager.register_listener(event_type_after_play, callback_after_play)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type_after_play, callback_after_play)
	
func get_description() -> String:
	var desc: String = super.get_description()
	if self.strength > 0:
		return desc.replace("entire farm", "entire farm, plus " + str(self.strength))
	return desc

func can_strengthen_custom_effect():
	return true
