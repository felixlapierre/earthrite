extends Fortune
class_name BlockRitual

var callback_harvest: Callable
var event_type_harvest = EventManager.EventType.OnManaGained
var event_type_preview = EventManager.EventType.OnYieldPreview
var texture_display = load("res://assets/fortune/BlockRitual.png")

var turn_start_event = EventManager.EventType.BeforeTurnStart
var turn_start_cb: Callable

func _init(strength: float = 1.0) -> void:
	super("Block", FortuneType.BadFortune, "Gain {STR_PER} less " + Helper.mana_icon() + " this turn.", -1, texture_display, strength)

func register_fortune(event_manager: EventManager):
	turn_start_cb = func(args: EventArgs):
		await popup_callback.call(true)
		await event_manager.farm.get_tree().create_timer(0.7).timeout
		
		# Do the obelisk visuals
		var texture: AtlasTexture = args.user_interface.Obelisk.texture_under
		texture.set_region(Rect2(32 * 7, 0, 32, 92))
		popup_callback.call(false)

	callback_harvest = func(args: EventArgs):
		if !args.specific.harvest_args.purple:
			args.specific.harvest_args.yld *= (1.0 - strength)
	
	event_manager.register_listener(turn_start_event, turn_start_cb)
	event_manager.register_listener(event_type_harvest, callback_harvest)
	event_manager.register_listener(event_type_preview, callback_harvest)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type_harvest, callback_harvest)
	event_manager.unregister_listener(event_type_preview, callback_harvest)
	event_manager.unregister_listener(turn_start_event, turn_start_cb)
	var damage_inc = min(ceil(event_manager.turn_manager.blight_damage / 20.0), 5)
	var texture: AtlasTexture = event_manager.user_interface.Obelisk.texture_under
	texture.set_region(Rect2(min(32 * damage_inc, 32 * 6), 0, 32, 92))
