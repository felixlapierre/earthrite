extends MageAbility
class_name VoidMageFortune

var icon = preload("res://assets/structure/temporal_rift.png")
static var MAGE_NAME = "Voidcaster"
var event_type = EventManager.EventType.BeforeTurnStart
var event_callable: Callable

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "At the start of the turn, gain 1" + Helper.blue_mana() + " per empty tile and 3" + Helper.blue_mana() + " per destroyed tile", 6, icon, 3.0)

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	update_text()
	event_callable = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.is_destroyed():
				args.farm.gain_yield(tile, EventArgs.HarvestArgs.new(strength, true, false))
			elif tile.state == Enums.TileState.Empty:
				args.farm.gain_yield(tile, EventArgs.HarvestArgs.new(1, true, false))
	event_manager.register_listener(event_type, event_callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, event_callable)

func upgrade_power():
	strength = 4.0
	update_text()

func update_text():
	text = "At the start of the turn, gain 1" + Helper.blue_mana() + " per empty tile and " + str(strength) + Helper.blue_mana() + " per destroyed tile"
