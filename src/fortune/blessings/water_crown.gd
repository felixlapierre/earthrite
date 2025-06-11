extends Fortune
class_name WaterCrown

var icon = preload("res://assets/mage/water_mage.png")

func _init() -> void:
	super("Frog King's Crown", Fortune.FortuneType.GoodFortune, "Watered tiles gain +50% mana when growing", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	Global.WATERED_MULTIPLIER += 0.5

func unregister_fortune(event_manager: EventManager):
	Global.WATERED_MULTIPLIER -= 0.5
