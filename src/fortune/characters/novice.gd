extends MageAbility
class_name NoviceFortune

static var MAGE_ID = 0
var icon = preload("res://assets/custom/YellowMana.png")

func _init() -> void:
	super("Novice", Fortune.FortuneType.GoodFortune, "Draw 1 extra card each turn", MAGE_ID, icon, 1.0)
	update_text()

func register_fortune(event_manager: EventManager):
	Constants.BASE_HAND_SIZE += int(strength)

func unregister_fortune(event_manager: EventManager):
	Constants.BASE_HAND_SIZE -= int(strength)

func upgrade_power():
	strength += 1.0
	Constants.BASE_HAND_SIZE += 1
	update_text()

func update_text():
	text = "Draw " + str(strength) + " extra cards each turn"
