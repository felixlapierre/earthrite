extends CardData
class_name Stormcall

var PickOption = preload("res://src/ui/pick_option.tscn")

var listener: Listener

func copy():
	var new = Stormcall.new()
	new.assign(self)
	return new

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	listener = Listener.new(EventManager.EventType.AfterCardPlayed, func(args: EventArgs):
		var options = []
		options.assign(WeatherDisplay.options)
		if strength < 2:
			options.erase(WeatherDisplay.in_two_weeks)
		options.shuffle()
		
		var pick_option_ui = PickOption.instantiate()
		args.user_interface.add_child(pick_option_ui)
		
		var on_pick = func(selected):
			args.user_interface.remove_child(pick_option_ui)
			WeatherDisplay.in_two_weeks = selected
			args.user_interface.update()

		pick_option_ui.setup("Choose a weather effect", options.slice(0, 3 + strength), on_pick, null))
	
	register(listener)

func unregister_events(event_manager: EventManager):
	listener.disable()

func can_strengthen_custom_effect():
	return true

func get_description():
	var color_pre = "[color=aqua]" if strength > 0 else ""
	var color_post = "[/color]" if strength > 0 else ""
	return "Pick 1 of " + color_pre + str(3 + strength) + color_post + " Weather effects to take place in 2 turns. " + super.get_description()
