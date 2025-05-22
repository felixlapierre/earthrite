extends Structure
class_name PurpleTotem

static var purple_mana = 5

var listener_turn_start: Listener
var listener_turn_end: Listener
var listener_year_start: Listener

var event_type = EventManager.EventType.OnTurnEnd
var event2 = EventManager.EventType.BeforeTurnStart
var event3 = EventManager.EventType.BeforeYearStart

func _init():
	super()
	call_deferred("update_text")

func update_text():
	if Global.LUNAR_FARM or Global.FARM_TYPE == "LUNARTEMPLE":
		text = text.replace("75%", "15%")

func copy():
	var copy = PurpleTotem.new()
	copy.assign(self)
	update_text()
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	var strength = 0.15 if Global.LUNAR_FARM or Global.FARM_TYPE == "LUNARTEMPLE" else 0.75
	update_text()
	
	listener_turn_end = Listener.new("lunartotem-turnend", event_type, func(args: EventArgs):
		if args.turn_manager.flag_defer_excess:
			self.purple_mana = 0
		else:
			self.purple_mana = args.turn_manager.purple_mana - args.turn_manager.target_blight
			self.purple_mana = 0 if self.purple_mana < 0 else self.purple_mana)

	listener_turn_start = Listener.new("lunartotem_turnstart", event2, func(args: EventArgs):
		args.turn_manager.purple_mana += ceil(self.purple_mana * strength)
		if self.purple_mana > 0:
			tile.play_effect_particles()
		self.purple_mana = 0)

	listener_year_start = Listener.new("lunartotem_yearstart", event3, func(args: EventArgs):
		self.purple_mana = 0)

	event_manager.register(listener_turn_start)
	event_manager.register(listener_turn_end)
	event_manager.register(listener_year_start)

func unregister_events(event_manager: EventManager):
	listener_turn_start.disable()
	listener_turn_end.disable()
	listener_year_start.disable()
