extends MageAbility
class_name AcornMageFortune

var icon = preload("res://assets/custom/acorn.png")
static var MAGE_NAME = "Druid"
static var MAGE_ID = 1

var event_type = EventManager.EventType.BeforeTurnStart
var callback: Callable

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Start with 1 Lucky Acorn. Find Lucky Acorns twice as often.\n\nTurn Start: Gain 1 " +  Helper.mana_icon() + " for each acorn found", MAGE_ID, icon, 1.0)

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	update_text()
	if event_manager.turn_manager.year < 1:
		Global.ACORNS += 1
		Global.TOTAL_ACORNS += 1
	
	callback = func(args: EventArgs):
		args.turn_manager.gain_yellow_mana(Global.TOTAL_ACORNS)
	event_manager.register_listener(event_type, callback)
	Global.ACORN_BONUS = strength

func unregister_fortune(event_manager: EventManager):
	Global.ACORN_BONUS = 0.0
	event_manager.unregister_listener(event_type, callback)

func upgrade_power():
	strength = 2.0
	Global.ACORN_BONUS = strength
	update_text()

func update_text():
	text = "Start with 1 Lucky Acorn. Find Lucky Acorns " + ("twice" if strength == 1.0 else "three times") + " as often.\n\nTurn Start: Gain 1 " +  Helper.mana_icon() + " for each acorn found"
