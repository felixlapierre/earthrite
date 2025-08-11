extends Effect2
class_name Shadowbind

var listener: Listener
var PickOption = preload("res://src/ui/pick_option.tscn")

func _init(p_delay = false):
	super(EventManager.EventType.AfterCardPlayed, false, Enums.EffectType.Other, "Shadowbind")

func register(event_manager: EventManager, tile: Tile):
	var cb = func(): pass

	listener = Listener.create(self, func(args: EventArgs):
		var options = args.cards.get_hand_info().filter(func(card):
			return card.can_strengthen_custom_effect() and !card.effects2.any(func(eff): return eff.name == "Dark Power"))
		if options.size() > 0:
			var pick_option_ui = PickOption.instantiate()
			args.user_interface.add_child(pick_option_ui)
			var prompt = "Pick a card (%s)" % owner.name
			var cancel_callback = null
			Global.LOCK = true
			pick_option_ui.setup(prompt, options, func(selected: CardData):
				var dark_power_effect = DarkPower.new()
				selected.effects2.append(dark_power_effect)
				dark_power_effect.owner = selected
				dark_power_effect.register(event_manager, null)
				dark_power_effect.listener.invoke(args)
				selected.updated.emit()
				Global.LOCK = false
				args.user_interface.remove_child(pick_option_ui), cancel_callback)
			await pick_option_ui.pick_finished
	)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()
	
func get_description(size):
	return "Apply [color=violet]Dark Power[/color] to a card in your hand that can be Strengthened"

func get_long_description():
	return Helper.get_long_description("dark_power")

func copy():
	var copy = Shadowbind.new()
	copy.assign(self)
	return copy
