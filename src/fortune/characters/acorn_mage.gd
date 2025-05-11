extends MageAbility
class_name AcornMageFortune

var icon = preload("res://assets/custom/acorn.png")
static var MAGE_NAME = "Druid"

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Start with 1 Lucky Acorn. Find Lucky Acorns twice as often.", 1, icon, 1.0)

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	update_text()
	if event_manager.turn_manager.year < 1:
		Global.ACORNS += 1
	Global.ACORN_BONUS = strength

func unregister_fortune(event_manager: EventManager):
	Global.ACORN_BONUS = 0.0

func upgrade_power():
	strength = 2.0
	Global.ACORN_BONUS = strength
	update_text()

func update_text():
	text = "Start with 1 Lucky Acorn. Find Lucky Acorns " + ("twice" if strength == 1.0 else "three times") + " as often."
