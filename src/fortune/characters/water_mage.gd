extends MageAbility
class_name WaterMage

var icon = preload("res://assets/mage/water_mage.png")
static var MAGE_NAME = "Water Mage"
func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "When a watered tile is watered again, Protect it.\nProtected tiles cannot be targeted by Blight attacks\nAdd a 'Dewdrop' to your deck", 2, icon)
	modify_deck_callback = func(deck: Array[CardData]):
		deck.append(load("res://src/cards/data/action/dewdrop.tres"))

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	Global.IRRIGATE_PROTECTED = true

func unregister_fortune(event_manager: EventManager):
	Global.IRRIGATE_PROTECTED = false

func update_text():
	text = "When a watered tile is watered again, Protect it.\nProtected tiles cannot be targeted by Blight attacks\nAdd a 'Dewdrop' to your deck"
