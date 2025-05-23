extends FarmType
class_name LunarTemple

static var ID = 4
static var NAME = "LUNARTEMPLE"
static var ICON = preload("res://assets/card/temporal_rift.png")
static var DESCR = "All tiles on the farm generated [color=aqua]Blue Mana[/color]" + Helper.blue_mana() + ".\n\nAt the end of the turn, 70% of [color=aqua]Blue Mana[/color] " + Helper.blue_mana() + " is converted to [color=gold]Yellow Mana[/color] " + Helper.mana_icon()

var listener_beforegrow: Listener
var listener_yearstart: Listener

func _init():
	super(ID, NAME, ICON, DESCR)

func register(event_manager: EventManager):
	listener_beforegrow = Listener.new(EventManager.EventType.BeforeGrow, func(args: EventArgs):
		if !args.turn_manager.flag_defer_excess:
			var excess = max(args.turn_manager.purple_mana - args.turn_manager.target_blight, 0)
			args.farm.gain_yield(args.farm.tiles[4][4], EventArgs.HarvestArgs.new(excess * 0.70, false, false))
		)

	listener_yearstart = Listener.new(EventManager.EventType.AfterYearStart, func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			tile.purple = true
			tile.update_display()
		)
	
	event_manager.register(listener_beforegrow)
	event_manager.register(listener_yearstart)

func unregister(event_manager: EventManager):
	listener_beforegrow.disable()
	listener_yearstart.disable()
