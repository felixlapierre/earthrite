extends MageAbility
class_name IceMageFortune

var icon = preload("res://assets/card/frostcut.png")
static var MAGE_NAME = "Frost Witch"
func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Your hand is not discarded at the end of the turn.", 1, icon, 1.0)

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	Global.END_TURN_DISCARD = false
	Global.MAX_HAND_SIZE = 11 if strength > 1.0 else 10

func unregister_fortune(event_manager: EventManager):
	Global.END_TURN_DISCARD = true
	Global.MAX_HAND_SIZE = 10

func upgrade_power():
	strength = 2.0
	Global.MAX_HAND_SIZE = 11 if strength > 1.0 else 10
	update_text()
	
func update_text():
	if strength == 2.0:
		text = "Your hand is not discarded at the end of the turn. Set maximum hand size to 11."
	else:
		text = "Your hand is not discarded at the end of the turn."
