extends Fortune
class_name FallBlessing

var icon = preload("res://assets/custom/YellowMana.png")
var callback
var event_type = EventManager.EventType.OnYieldPreview
var event_type_2 = EventManager.EventType.OnManaGained

func _init() -> void:
	super("Fall's Blessing", Fortune.FortuneType.GoodFortune, "Gain +20% [img]res://assets/custom/YellowMana.png[/img] in Fall", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		if args.turn_manager.week >= Global.FALL_WEEK and args.turn_manager.week < Global.WINTER_WEEK:
			if !args.specific.harvest_args.purple:
				args.specific.harvest_args.yld = ceil(args.specific.harvest_args.yld * 1.2)
				
	event_manager.register_listener(event_type, callback)
	event_manager.register_listener(event_type_2, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
	event_manager.unregister_listener(event_type_2, callback)
